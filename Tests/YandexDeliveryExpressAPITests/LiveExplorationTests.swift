import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// Asks the API what it actually does, and writes down the answer.
///
/// Yandex publishes no OpenAPI document and its HTML reference is incomplete, so
/// `openapi.yaml` is a hypothesis. This suite is the experiment. It is the tool that produced
/// every observation in the `WorkingWithYandex` article: an undocumented 409, five
/// undocumented fields, a misspelled field shipped alongside the correct one, a route point
/// the API invents, server-renumbered point ids, and two error-code vocabularies.
///
/// **It reports rather than asserts.** Raw exchanges are recorded as *attachments* and
/// findings as `.warning` issues, so a Yandex-side change shows up as a report instead of a
/// red build. The only things that fail here are client defects.
///
/// ```console
/// % AUTH_TOKEN="$(cat ~/.yandex-auth-token)" \
///     swift test --filter LiveExplorationTests --attachments-path .build/attachments
/// ```
///
/// `--attachments-path` is not optional: SwiftPM **discards attachments** without it, and the
/// whole point of this suite is the evidence it collects. Under `xcodebuild`, pass
/// `-resultBundlePath` and export with
/// `xcrun xcresulttool export attachments --path … --output-path …`.
///
/// Deliberately read-only. The mutating half of exploration lives in ``LiveMutatingTests``,
/// which creates a claim and cleans up after itself.
@Suite(
    "Live API (exploration)",
    .tags(.live, .exploration),
    .enabled(if: Credentials.environment != nil, "Set AUTH_TOKEN to run"),
    .timeLimit(.minutes(5)),
    .serialized
)
struct LiveExplorationTests {
    @Test("What does offers/calculate really send back?")
    func exploreCalculateOffers() async throws {
        let log = WireLog()
        let client = try Client.capturing(log, credentials: #require(Credentials.environment))

        let response = try await client.calculateOffers(
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(
                routePoints: .exampleMoscowRoute,
                items: .exampleSmallOrder,
                requirements: .init(taxiClasses: [.express])
            ))
        )

        let transcript = await log.transcript()
        Attachment.record(transcript, named: "offers-calculate.txt")

        let exchange = try #require(await log.exchanges.last)
        guard let raw = exchange.responseBody else { return }

        // The TD-16 census, attached rather than argued about.
        let shapes = WireDrift.timestampShapes(in: raw)
        Attachment.record(
            shapes.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: "\n"),
            named: "offers-calculate-timestamp-shapes.txt"
        )
        if shapes.count > 1 {
            Issue.record(
                "One response mixed \(shapes.count) timestamp shapes: \(shapes). This is TD-16 and it is why the reader stays permissive.",
                severity: .warning
            )
        }

        // Fields Yandex sends that `openapi.yaml` does not describe.
        if let decoded = try? response.ok.body.json {
            let unknown = WireDrift.undocumented(in: raw, understoodAs: decoded)
            if !unknown.isEmpty {
                Attachment.record(unknown.joined(separator: "\n"), named: "offers-calculate-undocumented-fields.txt")
                Issue.record(
                    "offers/calculate sends \(unknown.count) field(s) openapi.yaml does not model: \(unknown.joined(separator: ", "))",
                    severity: .warning
                )
            }
        }

        // The client must still work. That part is an assertion.
        #expect((try? response.ok.body.json.offers.isEmpty) == false)
    }

    @Test("Which statuses does the API answer with that we do not document?")
    func exploreUndocumentedStatuses() async throws {
        // Every `.undocumented` here is a bug in *our* document (`SpecOwnership`), and this is
        // how TD-17 was found. Each probe is read-only and deliberately malformed in one way.
        let log = WireLog()
        let client = try Client.capturing(log, credentials: #require(Credentials.environment))
        var findings: [String] = []

        // 1. A tariff combination the domain refuses — how the undocumented 409 surfaced.
        let loadersOnExpress = try await client.calculateOffers(
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(
                routePoints: .exampleMoscowRoute,
                items: .exampleSmallOrder,
                requirements: .init(cargoLoaders: 4, taxiClasses: [.express])
            ))
        )
        if case .undocumented(let code, _) = loadersOnExpress {
            findings.append("calculateOffers(cargoLoaders on express) → undocumented \(code)")
        }

        // 2. A claim id that violates the documented length.
        let shortId = try await client.getClaimInfo(
            query: .init(claimId: "abc"),
            headers: .init(acceptLanguage: .ru)
        )
        if case .undocumented(let code, _) = shortId {
            findings.append("getClaimInfo(short id) → undocumented \(code)")
        }

        // 3. A well-formed id that does not exist.
        let absent = try await client.getClaimCancelInfo(
            query: .init(claimId: String(repeating: "f", count: 32)),
            headers: .init(acceptLanguage: .ru)
        )
        if case .undocumented(let code, _) = absent {
            findings.append("getClaimCancelInfo(absent id) → undocumented \(code)")
        }

        Attachment.record(await log.transcript(), named: "undocumented-status-probes.txt")

        if findings.isEmpty {
            // Success means the document currently covers what we probed. Worth recording.
            Issue.record("No undocumented statuses on the probed paths.", severity: .warning)
        } else {
            Issue.record(
                "openapi.yaml is missing \(findings.count) status(es): \(findings.joined(separator: "; ")). Add them to the document, not to Swift.",
                severity: .warning
            )
        }
    }

    @Test("Is the error `code` field a vocabulary or a status code?")
    func exploreErrorCodeVocabulary() async throws {
        // Observed: symbolic codes (`not_found`, `state_mismatch`, `estimating.too_many_loaders`)
        // *and* numeric strings (`"400"`), in one API. A caller switching on `code` needs to
        // know that before it writes the switch.
        let log = WireLog()
        let client = try Client.capturing(log, credentials: #require(Credentials.environment))
        var codes: [String] = []

        if case .badRequest(let error) = try await client.getClaimInfo(
            query: .init(claimId: "abc"), headers: .init(acceptLanguage: .ru)
        ), let code = try? error.body.json.code {
            codes.append(code)
        }
        if case .notFound(let error) = try await client.getClaimInfo(
            query: .init(claimId: String(repeating: "f", count: 32)), headers: .init(acceptLanguage: .ru)
        ), let code = try? error.body.json.code {
            codes.append(code)
        }

        Attachment.record(await log.transcript(), named: "error-code-probes.txt")
        Attachment.record(codes.joined(separator: "\n"), named: "error-codes.txt")

        let numeric = codes.filter { Int($0) != nil }
        if !numeric.isEmpty {
            Issue.record(
                "`code` carried \(numeric.count) numeric value(s) \(numeric) alongside symbolic ones \(codes.filter { Int($0) == nil }). Two vocabularies in one field — do not switch on it as an enum.",
                severity: .warning
            )
        }
    }
}

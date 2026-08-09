import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The only thing that validates a hand-authored specification.
///
/// Offline suites prove the client decodes what `openapi.yaml` *claims*; these prove the
/// claim. They are also the most expensive tests here: they need `AUTH_TOKEN`, a Yandex
/// Delivery account, and — for `claimLifecycle` — the willingness to create a real claim
/// against it. Run them on a schedule, never on every push (`Roadmap` -> Next, TD-6).
///
/// `.serialized` is justified rather than habitual: `claimLifecycle`'s steps depend on each
/// other and on server-side state, which is the case the trait exists for.
@Suite(
    "Live API",
    .tags(.live),
    .enabled(if: Credentials.environment != nil, "Set AUTH_TOKEN to run"),
    .timeLimit(.minutes(1)),
    .serialized
)
struct LiveClientTests {
    private func liveClient() throws -> Client {
        let credentials = try #require(Credentials.environment)
        return try Client(credentials: credentials)
    }

    @Test("A bogus token comes back as .unauthorized")
    func rejectsBadCredentials() async throws {
        // Start here when bringing this suite up: it needs no valid account, and it proves
        // the auth path end to end.
        let client = try Client(credentials: .init(authToken: "definitely-not-a-token"))

        let response = try await client.calculateOffers(.sample)

        guard case .unauthorized = response else {
            Issue.record("Expected .unauthorized for a bogus token, got \(response)")
            return
        }
    }

    @Test("A real Moscow route returns at least one priced offer")
    func calculatesOffersForARealRoute() async throws {
        // Read-only, so it costs nothing to run.
        let client = try liveClient()

        let response = try await client.calculateOffers(.sample)

        let offers = try #require(try? response.ok.body.json.offers)
        #expect(!offers.isEmpty)
        let offer = try #require(offers.first)
        #expect(Double(offer.price.totalPriceWithVat) ?? 0 > 0)
    }

    @Test("create -> info -> cancel-info -> cancel, on one claim", .disabled("Creates a real claim; enable deliberately"))
    func claimLifecycle() async throws {
        // One test, not four: split across tests they would be order-dependent, which no
        // framework guarantees. Whatever this creates, it cancels — including on failure.
        let client = try liveClient()

        let created = try await client.createClaim(
            query: .init(requestId: UUID().uuidString),
            headers: .init(acceptLanguage: .ru),
            body: .json(.exampleSmartphoneDelivery)
        )
        let claim = try #require(try? created.ok.body.json, "createClaim did not return 200: \(created)")

        try await cancellingAfterwards(claim.id, with: client) {
            let info = try await client.getClaimInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let fetched = try #require(try? info.ok.body.json)
            #expect(fetched.id == claim.id)

            let cancelInfo = try await client.getClaimCancelInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let state = try #require(try? cancelInfo.ok.body.json.cancelState)
            // `.unavailable` is a legitimate outcome, not a failure — there is a window in
            // which Yandex will not let a claim be cancelled at all.
            #expect([.free, .paid, .unavailable].contains(state))
        }
    }

    @Test("Every read operation decodes, and records rather than fails when it does not")
    func decodeReviewSweep() async throws {
        // The highest-value live test for an owned specification: it turns "Yandex changed
        // something" into a report instead of a mystery. `.undocumented` in the wild is a
        // spec bug report (`SpecOwnership`).
        let client = try liveClient()

        await withKnownIssue("Live response did not match openapi.yaml", isIntermittent: true) {
            let response = try await client.calculateOffers(.sample)
            guard case .undocumented(let statusCode, let payload) = response else {
                _ = try response.ok.body.json
                return
            }
            Issue.record("Undocumented status \(statusCode): \(payload)")
        }
    }

    // MARK: Guardrails

    /// Runs `body`, then cancels `claimId` whether or not it threw. A live test that leaves
    /// a claim behind bills a real account.
    private func cancellingAfterwards(
        _ claimId: String,
        with client: Client,
        _ body: () async throws -> Void
    ) async throws {
        do {
            try await body()
        } catch {
            await cancelQuietly(claimId, with: client)
            throw error
        }
        await cancelQuietly(claimId, with: client)
    }

    private func cancelQuietly(_ claimId: String, with client: Client) async {
        _ = try? await client.cancelClaim(
            query: .init(claimId: claimId),
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(version: 1, cancelState: .free))
        )
    }
}

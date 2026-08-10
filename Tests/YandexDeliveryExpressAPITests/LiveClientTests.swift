import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The read-only half of live validation — the only thing that checks a hand-authored
/// specification against the API it describes.
///
/// Offline suites prove the client decodes what `openapi.yaml` *claims*; these prove the
/// claim. They need `AUTH_TOKEN` and a Yandex Delivery account, so they run on a schedule
/// rather than on every push (`Roadmap` -> Next, TD-6).
///
/// Nothing here changes server-side state; the lifecycle that does lives in
/// ``LiveMutatingTests`` behind a second switch.
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

}

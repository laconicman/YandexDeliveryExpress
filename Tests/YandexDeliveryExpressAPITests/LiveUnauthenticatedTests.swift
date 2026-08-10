import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// Runs when the machine has credentials — as before — **or** when network tests are opted
/// into without them, which is the case this suite exists to reach.
private var unauthenticatedLiveTestsAreEnabled: Bool {
    Credentials.environment != nil
        || ProcessInfo.processInfo.environment["YDE_ALLOW_NETWORK_TESTS"] == "1"
}

/// The live check that needs no account.
///
/// Split out of ``LiveClientTests`` because it was gated on exactly the thing it does not
/// need: it builds its own client with a deliberately bad token, yet inherited a suite-level
/// `.enabled(if: Credentials.environment != nil)`, so it never ran on the machine where it
/// is cheapest and most useful — one with no `AUTH_TOKEN` at all.
///
/// What it buys is the whole auth path end to end for free: the server URL resolves, the
/// middleware attaches the header, Yandex rejects it, and the client decodes that rejection
/// into the documented `.unauthorized` case rather than throwing. That is most of the
/// transport wiring, verified without an account.
///
/// ```console
/// % YDE_ALLOW_NETWORK_TESTS=1 swift test --filter "Live API (unauthenticated)"
/// ```
///
/// Still named "Live API", so one `--skip "Live API"` keeps the CI default offline.
@Suite(
    "Live API (unauthenticated)",
    .tags(.live),
    .enabled(if: unauthenticatedLiveTestsAreEnabled, "Set AUTH_TOKEN, or YDE_ALLOW_NETWORK_TESTS=1 to run without an account"),
    .timeLimit(.minutes(1))
)
struct LiveUnauthenticatedTests {
    @Test("A bogus token comes back as .unauthorized, not as a thrown error")
    func rejectsBadCredentials() async throws {
        let client = try Client(credentials: .init(authToken: "definitely-not-a-token"))

        let response = try await client.calculateOffers(.sample)

        // The two-channel rule under live conditions: a documented 401 is a case to switch
        // on, and only transport or decoding failures throw.
        guard case .unauthorized(let error) = response else {
            Issue.record("Expected .unauthorized for a bogus token, got \(response)")
            return
        }
        // And the shared error body decodes, which is the shape every other documented
        // failure in this API reuses.
        #expect((try? error.body.json.message) != nil)
    }
}

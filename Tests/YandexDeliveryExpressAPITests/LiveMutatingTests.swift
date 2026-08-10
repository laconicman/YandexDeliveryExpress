import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The manual path: the whole claim lifecycle against a real account, end to end.
///
/// Separated from ``LiveClientTests`` because everything here **changes server-side state**.
/// `AUTH_TOKEN` alone cannot tell a test account from a production one, so this suite needs
/// a second, deliberate switch:
///
/// ```console
/// % AUTH_TOKEN=… YDE_ALLOW_MUTATING_LIVE_TESTS=1 swift test --filter "Live API (mutating)"
/// ```
///
/// Run it against **test credentials**. Both gates are checked, the suite is `.serialized`,
/// and whatever it creates it cancels — including when an expectation fails part-way.
///
/// `--skip "Live API"` skips this suite too, so the CI default is unaffected by its
/// existence.
/// Both gates, read at suite-construction time. A file-scope function rather than a static
/// on the suite: an `@Suite` trait cannot refer to a member of the type it is attached to.
private var mutatingLiveTestsAreEnabled: Bool {
    Credentials.environment != nil
        && ProcessInfo.processInfo.environment["YDE_ALLOW_MUTATING_LIVE_TESTS"] == "1"
}

@Suite(
    "Live API (mutating)",
    .tags(.live, .mutating),
    .enabled(if: mutatingLiveTestsAreEnabled, "Set AUTH_TOKEN and YDE_ALLOW_MUTATING_LIVE_TESTS=1 to run"),
    .timeLimit(.minutes(5)),
    .serialized
)
struct LiveMutatingTests {
    @Test("create -> info -> cancel-info -> cancel, on one claim")
    func claimLifecycle() async throws {
        // One test, not four: split across tests these would be order-dependent, which no
        // framework guarantees, and a failure half way would strand a claim.
        let client = try Client(credentials: #require(Credentials.environment))

        let created = try await client.createClaim(
            query: .init(requestId: UUID().uuidString),
            headers: .init(acceptLanguage: .ru),
            body: .json(.exampleSmartphoneDelivery)
        )
        let claim = try #require(try? created.ok.body.json, "createClaim did not return 200: \(created)")
        #expect(claim.status == .new || claim.status == .estimating || claim.status == .readyForApproval)

        try await cancelling(claim.id, with: client) {
            let info = try await client.getClaimInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let fetched = try #require(try? info.ok.body.json)
            #expect(fetched.id == claim.id)
            #expect(fetched.routePoints.count == 2)

            let cancelInfo = try await client.getClaimCancelInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let state = try #require(try? cancelInfo.ok.body.json.cancelState)
            // `.unavailable` is a legitimate outcome, not a failure: there is a window in
            // which Yandex will not let a claim be cancelled at all.
            #expect([.free, .paid, .unavailable].contains(state))
            // An unaccepted claim should still be free to cancel. If this ever reports
            // `.paid`, the guarantee this whole suite rests on is gone — read it before
            // running again.
            #expect(state != .paid, "Cancelling an unaccepted claim was billable")
        }
    }

    // MARK: Guardrails

    /// Runs `body`, then cancels `claimId` whether or not it threw, and asserts that the
    /// cancellation actually landed. A run that leaves a claim behind bills the account.
    private func cancelling(
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

        let cancelled = try await client.cancelClaim(
            query: .init(claimId: claimId),
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(version: 1, cancelState: .free))
        )
        let result = try #require(try? cancelled.ok.body.json, "cancelClaim did not return 200: \(cancelled)")
        #expect(result.status == .cancelled)
    }

    private func cancelQuietly(_ claimId: String, with client: Client) async {
        _ = try? await client.cancelClaim(
            query: .init(claimId: claimId),
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(version: 1, cancelState: .free))
        )
    }
}

// MARK: - Not covered live, deliberately
//
// `acceptClaim` is the one operation with no live test. Accepting is what starts the real
// courier search, and it is the step that makes a cancellation billable — a suite that
// accepts cannot also promise to cancel for free. Exercising it needs a Yandex sandbox
// account rather than a guardrail, which is recorded in the DocC `TechDebt` article.

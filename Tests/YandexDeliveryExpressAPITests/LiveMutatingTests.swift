import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// Both gates, read at suite-construction time. A file-scope constant rather than a static
/// on the suite: an `@Suite` trait cannot refer to a member of the type it is attached to.
private var mutatingLiveTestsAreEnabled: Bool {
    Credentials.environment != nil
        && ProcessInfo.processInfo.environment["YDE_ALLOW_MUTATING_LIVE_TESTS"] == "1"
}

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
/// and whatever it creates it cancels — using the version and cancel state the API just
/// reported, not values guessed in advance.
///
/// `--skip "Live API"` skips this suite too, so the CI default is unaffected by its
/// existence.
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

        // Captured *before* the call, because the dangerous case is the one where we never
        // learn the claim id: a 5xx, a timeout after the server accepted, or a 200 whose
        // body will not decode. `request_id` is the API's idempotency token, and the
        // document is explicit that reusing it returns the claim already created rather than
        // creating a second one — and about the cost of getting that wrong, which is two
        // couriers arriving for one delivery.
        let requestId = UUID().uuidString

        let created: Operations.CreateClaim.Output
        do {
            created = try await client.createClaim(
                query: .init(requestId: requestId),
                headers: .init(acceptLanguage: .ru),
                body: .json(.exampleSmartphoneDelivery)
            )
        } catch {
            // Ambiguous: a transport failure can mean the server never saw the request, or
            // saw it, created the claim, and lost the response. Ask, using the same token.
            await recoverAndCancel(requestId: requestId, with: client)
            throw error
        }

        guard case .ok(let ok) = created else {
            // *Not* ambiguous. Yandex answered with a documented refusal — a 400 or a 401 —
            // so no claim was created and there is nothing to clean up. Recovering here
            // would post `createClaim` again and bring into existence the very claim we
            // were trying not to leave behind.
            Issue.record("createClaim was refused, so nothing was created: \(created)")
            return
        }
        guard let claim = try? ok.body.json else {
            // A 200 we cannot read: the claim almost certainly exists and we do not have its
            // id, which is exactly what the idempotency token is for.
            await recoverAndCancel(requestId: requestId, with: client)
            Issue.record("createClaim returned 200 with a body that would not decode")
            return
        }
        #expect([.new, .estimating, .readyForApproval].contains(claim.status))

        // What the cancellation will be built from, refreshed as the API tells us more. A
        // claim's version moves as it progresses server-side, so cancelling with a stale one
        // is rejected — which is how a "guardrail" leaves a live claim behind.
        var cancellation = Cancellation(version: claim.version, state: .free)

        do {
            let info = try await client.getClaimInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let fetched = try #require(try? info.ok.body.json)
            cancellation.version = fetched.version
            #expect(fetched.id == claim.id)
            // Three, not the two we sent: Yandex appends a `return` point of its own, and
            // renumbers every point with server-assigned int64 ids. Observed 2026-08-12 —
            // see the `WorkingWithYandex` article.
            #expect(fetched.routePoints.count == 3)
            #expect(fetched.routePoints.map(\._type) == [.source, .destination, ._return])

            let cancelInfo = try await client.getClaimCancelInfo(
                query: .init(claimId: claim.id),
                headers: .init(acceptLanguage: .ru)
            )
            let observed = try #require(try? cancelInfo.ok.body.json.cancelState)
            // `CancelInfoCancelState` has a third case `CancelState` does not, which is the
            // whole reason the document says «Не путать с CancelState». `.unavailable`
            // cannot be echoed back, so the best we can do is try `.free` and shout if it
            // fails.
            switch observed {
            case .free:
                cancellation.state = .free
            case .paid:
                cancellation.state = .paid
                Issue.record("Cancelling an unaccepted claim was billable — the premise this suite rests on is gone")
            case .unavailable:
                cancellation.state = .free
                Issue.record("Yandex reports cancellation unavailable for \(claim.id); attempting anyway")
            }
        } catch {
            // Same shout as the other two cleanup sites. Discarding this result was the
            // third hole in this guardrail: a read failing mid-lifecycle would surface only
            // the read error, and a claim left running would say nothing at all.
            let cancelled = await cancel(claim.id, cancellation, with: client)
            #expect(cancelled, "Could not cancel \(claim.id) — CANCEL IT BY HAND, the account is being billed for it")
            throw error
        }

        try await cancelAndAssert(claim.id, cancellation, with: client)
    }

    // MARK: Guardrails

    private struct Cancellation {
        var version: Int64
        var state: Components.Schemas.CancelState
    }

    /// Last resort for the case where the claim id was never learned.
    ///
    /// Re-posts `createClaim` with the **same** `request_id`. Per the document that returns
    /// the claim the server already created, so this is a read dressed as a write; if no
    /// claim existed, it creates one and we cancel that instead, which is a strictly better
    /// outcome than leaving an unknown claim running. Either way the account ends up with
    /// nothing live.
    private func recoverAndCancel(requestId: String, with client: Client) async {
        guard let created = try? await client.createClaim(
            query: .init(requestId: requestId),
            headers: .init(acceptLanguage: .ru),
            body: .json(.exampleSmartphoneDelivery)
        ),
        let claim = try? created.ok.body.json
        else {
            Issue.record(
                """
                Could not establish whether a claim exists for request_id \(requestId). \
                CHECK THE ACCOUNT BY HAND — a billable claim may be running.
                """
            )
            return
        }

        let cancelled = await cancel(claim.id, .init(version: claim.version, state: .free), with: client)
        #expect(cancelled, "Recovered claim \(claim.id) but could not cancel it — CANCEL IT BY HAND")
    }

    /// Cancels, and fails the test if the claim is still alive afterwards.
    private func cancelAndAssert(
        _ claimId: String,
        _ cancellation: Cancellation,
        with client: Client
    ) async throws {
        let outcome = await cancel(claimId, cancellation, with: client)
        #expect(outcome, "Could not cancel \(claimId) — CANCEL IT BY HAND, the account is being billed for it")
    }

    /// One cancellation attempt, then — if the version was the problem — one retry with the
    /// version re-read from the API. Returns whether the claim ended up cancelled.
    ///
    /// ## Why one retry, and the open question
    ///
    /// A cancellation carries the claim's `version`, and a claim's version moves on its own
    /// as it progresses `new → estimating → ready_for_approval` server-side. So the version
    /// read a moment ago can be stale by the time the cancellation lands — a race that is
    /// *expected* here rather than exceptional, and the failure it produces costs money
    /// rather than a red test. Re-reading and trying once directly addresses that cause.
    ///
    /// The argument against, which is not weak: a retry in a cleanup path can launder a
    /// systematic failure into a transient-looking one. If cancellation is failing for a
    /// structural reason — the claim is already accepted, the token lacks the scope, the
    /// endpoint changed — we now issue two requests and report the same failure, having
    /// made the log twice as confusing and taken twice as long to get there.
    ///
    /// It is bounded at exactly one retry for that reason: enough to beat the race, too few
    /// to look like resilience. The retry also deliberately re-reads rather than blindly
    /// repeating, so a second failure is evidence about something other than the version.
    ///
    /// **Open question for whoever runs this against a real account first.** Collect what
    /// actually fails. If the retry never fires, delete it — it is speculative machinery in
    /// a path that must stay legible. If it fires and *succeeds*, it has earned its place
    /// and the version race is real and worth naming in the Design article. If it fires and
    /// fails, that is the interesting case: the first attempt's rejection was never about
    /// the version, and this helper is answering the wrong question. Asked of Devin in the
    /// PR-1 discussion; no data either way yet, because nothing has run this live.
    @discardableResult
    private func cancel(
        _ claimId: String,
        _ cancellation: Cancellation,
        with client: Client
    ) async -> Bool {
        if await cancelOnce(claimId, cancellation, with: client) { return true }

        // A rejected cancellation is most often a stale `version`: the claim moved on
        // between the read and the write. Re-read it and try once more, rather than
        // abandoning a live claim.
        guard let fresh = try? await client.getClaimInfo(
            query: .init(claimId: claimId),
            headers: .init(acceptLanguage: .ru)
        ),
        let reread = try? fresh.ok.body.json
        else { return false }

        return await cancelOnce(claimId, .init(version: reread.version, state: cancellation.state), with: client)
    }

    private func cancelOnce(
        _ claimId: String,
        _ cancellation: Cancellation,
        with client: Client
    ) async -> Bool {
        guard let response = try? await client.cancelClaim(
            query: .init(claimId: claimId),
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(version: cancellation.version, cancelState: cancellation.state))
        ),
        let body = try? response.ok.body.json
        else { return false }

        return body.status == .cancelled || body.status == .cancelledWithPayment
    }
}

// MARK: - Not covered live, deliberately
//
// `acceptClaim` is the one operation with no live test. Accepting is what starts the real
// courier search, and it is the step that makes a cancellation billable — a suite that
// accepts cannot also promise to cancel for free. Exercising it needs a Yandex sandbox
// account rather than a guardrail, which is recorded in the DocC `TechDebt` article (TD-11).

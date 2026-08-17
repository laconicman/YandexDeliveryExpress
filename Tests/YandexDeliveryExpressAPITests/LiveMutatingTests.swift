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
            // Not every non-2xx means the same thing, and `openapi.yaml`'s own `request_id`
            // documentation says which: on a 5xx **or a timeout**, reuse the token, because
            // the claim may already exist. So a server error is as ambiguous as a dropped
            // connection, and lumping it in with a 400 skips the cleanup entirely.
            if createOutcomeIsAmbiguous(created) {
                await recoverAndCancel(requestId: requestId, with: client)
                Issue.record("createClaim returned a 5xx, which is ambiguous: \(created)")
            } else {
                // A 400 or a 401 *is* definite — nothing was created, and recovering here
                // would post `createClaim` again and bring into existence the very claim we
                // were trying not to leave behind.
                Issue.record("createClaim was refused, so nothing was created: \(created)")
            }
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

    struct Cancellation {
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

    /// Cancels, re-reading the claim between attempts, up to three times.
    ///
    /// Returns whether the claim ended up cancelled.
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
    /// Reuse hook for ``LiveAcceptClaimTests``, which must not re-implement the guardrail.
    func cancelForReuse(_ id: String, _ c: Cancellation, with client: Client) async -> Bool {
        await cancel(id, c, with: client)
    }

    @discardableResult
    private func cancel(
        _ claimId: String,
        _ cancellation: Cancellation,
        with client: Client
    ) async -> Bool {
        var attempt = cancellation

        for round in 0..<3 {
            if await cancelOnce(claimId, attempt, with: client) { return true }

            // Re-read *status*, not only `version`. The one failure observed live was
            // `409 state_mismatch` while the claim was mid-estimation — a transient state, not
            // a stale version — and the same claim cancelled cleanly minutes later. Retrying
            // immediately with a refreshed version would have failed for the same reason, which
            // is what the first version of this helper did.
            guard let fresh = try? await client.getClaimInfo(
                query: .init(claimId: claimId),
                headers: .init(acceptLanguage: .ru)
            ),
            let reread = try? fresh.ok.body.json
            else { return false }

            if reread.status == .cancelled || reread.status == .cancelledWithPayment { return true }
            attempt.version = reread.version

            // Only a claim still moving is worth waiting for. A terminal status will not
            // become cancellable by waiting, so stop rather than burn the budget.
            let isSettling = reread.status == .new || reread.status == .estimating
            guard isSettling, round < 2 else { break }
            try? await Task.sleep(for: .seconds(3))
        }

        return false
    }

    /// `.internalServerError`, or any undocumented 5xx: the request may or may not have
    /// created a claim, so the idempotency token is the only way to find out.
    private func createOutcomeIsAmbiguous(_ output: Operations.CreateClaim.Output) -> Bool {
        switch output {
        case .internalServerError: true
        case .undocumented(let statusCode, _): (500..<600).contains(statusCode)
        default: false
        }
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

/// Accepting is the one operation the other suites will not touch, because on a production
/// account it starts a real courier search and turns a later cancellation from free into
/// billable. On a **test** account it costs nothing — so it gets a third switch of its own
/// rather than riding on the mutating gate:
///
/// ```console
/// % AUTH_TOKEN=… YDE_ALLOW_MUTATING_LIVE_TESTS=1 YDE_ACCOUNT_IS_TEST=1 \
///     swift test --filter LiveAcceptClaimTests
/// ```
///
/// Three gates is not paranoia. `AUTH_TOKEN` says a credential exists; the mutating switch
/// says server state may change; this one says *whose* money is on the table. Nothing else in
/// the suite can assert that, and the difference is the whole reason TD-11 stayed open.
@Suite(
    "Live API (mutating, accept)",
    .tags(.live, .mutating),
    .enabled(
        if: mutatingLiveTestsAreEnabled && ProcessInfo.processInfo.environment["YDE_ACCOUNT_IS_TEST"] == "1",
        "Needs AUTH_TOKEN, YDE_ALLOW_MUTATING_LIVE_TESTS=1 and YDE_ACCOUNT_IS_TEST=1"
    ),
    .timeLimit(.minutes(5)),
    .serialized
)
struct LiveAcceptClaimTests {
    @Test("acceptClaim, the only operation with no other live coverage (TD-11)")
    func acceptsAClaim() async throws {
        let log = WireLog()
        let client = try Client.capturing(log, credentials: #require(Credentials.environment))

        // A short central-Moscow courier run, because the express sample never estimates on
        // this account — it lands in `estimating_failed`, and a claim can only be accepted
        // from `ready_for_approval`. See TD-11.
        let created = try await client.createClaim(
            query: .init(requestId: UUID().uuidString),
            headers: .init(acceptLanguage: .ru),
            body: .json(.exampleAcceptableCourierRun)
        )
        guard let claim = try? created.ok.body.json else {
            Issue.record("createClaim did not return a decodable 200: \(created)")
            return
        }

        // A claim is only acceptable once estimation has produced an offer. Poll rather than
        // assume: the observed progression is `new` -> `estimating` -> `ready_for_approval`,
        // and it can also land in `estimating_failed`, which is a legitimate outcome for a
        // route the account cannot service right now.
        var status = claim.status
        var version = claim.version
        for _ in 0..<15 where status == .new || status == .estimating {
            try await Task.sleep(for: .seconds(2))
            guard let info = try? await client.getClaimInfo(query: .init(claimId: claim.id), headers: .init(acceptLanguage: .ru)),
                  let fetched = try? info.ok.body.json else { break }
            status = fetched.status
            version = fetched.version
        }
        Attachment.record(await log.transcript(), named: "accept-claim.txt")

        guard status == .readyForApproval else {
            Issue.record("Claim reached \(status.rawValue) rather than ready_for_approval, so acceptClaim was not exercised. Not a client defect.", severity: .warning)
            let cancelled = await cancel(claim.id, .init(version: version, state: .free), with: client)
            #expect(cancelled, "Could not cancel \(claim.id) after \(status.rawValue) — CANCEL IT BY HAND")
            return
        }

        let accepted = try await client.acceptClaim(
            query: .init(claimId: claim.id),
            headers: .init(acceptLanguage: .ru),
            body: .json(.init(version: version))
        )
        Attachment.record(await log.transcript(), named: "accept-claim-full.txt")

        // The point of TD-11: `ClaimAcceptResponse` has never been checked against the wire.
        if let body = try? accepted.ok.body.json {
            #expect(body.id == claim.id)
            #expect(body.status == .accepted || body.status == .performerLookup)
        } else {
            Issue.record("acceptClaim did not return a decodable 200: \(accepted)", severity: .warning)
        }

        // Accepted or not, do not leave it running.
        let cancelled = await cancel(claim.id, .init(version: version, state: .free), with: client)
        #expect(cancelled, "Could not cancel \(claim.id) after accepting — CANCEL IT BY HAND")
    }

    /// Reuse the guardrail rather than re-implementing it. There is deliberately no
    /// single-attempt variant here: after four rounds of holes in this cleanup path, a second
    /// way to cancel is the last thing this file needs.
    private func cancel(_ id: String, _ c: LiveMutatingTests.Cancellation, with client: Client) async -> Bool {
        await LiveMutatingTests().cancelForReuse(id, c, with: client)
    }
}

import Foundation
import HTTPTypes
import Testing
@testable import YandexDeliveryExpressAPI

/// The claims-discovery pair added in 0.3.0: `claims/journal` (an account-wide change feed)
/// and `claims/search` (a paginated filter/continuation lookup). Both fixtures are live
/// captures from 2026-09-23, so these pin what the wire actually sent — including the parts
/// the reference does not mention.
@Suite("Journal and search", .tags(.specContract))
struct JournalSearchTests {

    // MARK: Journal — decoding

    @Test("A journal page decodes its events, including the terminal resolution")
    func decodesJournalEvents() async throws {
        let client = try Client.stubbed(json: Fixture.claimsJournalResponseJSON)

        let response = try await client.getClaimsJournal()

        let page = try #require(try? response.ok.body.json)
        #expect(page.events.count == 4)

        // The cursor is opaque — a JWT on the wire — and the client's whole job is to hand
        // it back verbatim. Asserting the exact string pins that nothing decodes it.
        #expect(page.cursor.hasPrefix("eyJ"))

        let first = try #require(page.events.first)
        #expect(first.operationId == 84)
        #expect(first.claimId == "01a0cd38be93807496944ebfc9654d02")
        #expect(first.changeType == .statusChanged)
        #expect(first.newStatus == .new)
        #expect(first.revision == 1)
        #expect(first.currentPointId == 17_594_193_737_507)
        #expect(first.resolution == nil)

        // The terminal event of a user-initiated cancel reports `resolution: "failed"` —
        // "success" means delivered, not "the action worked". Observed live 2026-09-23.
        let terminal = try #require(page.events.last)
        #expect(terminal.newStatus == .cancelled)
        #expect(terminal.resolution == .failed)
        #expect(abs(terminal.updatedTs.timeIntervalSince1970 - 1_790_149_493.304895) < 0.001)
    }

    @Test("An empty journal page decodes")
    func decodesEmptyJournalPage() async throws {
        let client = try Client.stubbed(json: Fixture.claimsJournalEmptyJSON)

        let response = try await client.getClaimsJournal()

        let page = try #require(try? response.ok.body.json)
        #expect(page.cursor == "opaque-journal-cursor")
        #expect(page.events.isEmpty)
    }

    // MARK: Journal — encoding

    @Test("Journal sends the limit as a query parameter and the cursor in the body")
    func journalEncodesLimitAndCursor() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.claimsJournalEmptyJSON)

        _ = try await client.getClaimsJournal(
            query: .init(limit: 50),
            body: .json(.init(cursor: "opaque-journal-cursor"))
        )

        let request = try #require(await recorder.request)
        #expect(request.method == .post)
        #expect(request.path == "/claims/journal?limit=50")

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        #expect(json["cursor"] as? String == "opaque-journal-cursor")
        #expect(json.count == 1)
    }

    @Test("Journal accepts no body at all — the wire permits it")
    func journalSendsNoBodyWhenOmitted() async throws {
        // Verified live 2026-09-23: no body, `{}` and `{"cursor": "…"}` all return 200, so
        // the document marks the whole requestBody optional and the generated `body`
        // parameter defaults to nil.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.claimsJournalEmptyJSON)

        _ = try await client.getClaimsJournal()

        let request = try #require(await recorder.request)
        #expect(request.method == .post)
        #expect(request.path == "/claims/journal")
        #expect(await recorder.requestBody == nil)
    }

    // MARK: Search — decoding

    @Test("A search page decodes full claims and keeps the opaque cursor")
    func decodesSearchClaimsResponse() async throws {
        let client = try Client.stubbed(json: Fixture.searchClaimsResponseJSON)

        let response = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCorp(.init(limit: 50)))
        )

        let page = try #require(try? response.ok.body.json)
        #expect(page.cursor?.hasPrefix("eyJ") == true)
        let claim = try #require(page.claims.first)
        #expect(claim.id == "01a0cd38be93807496944ebfc9654d02")
        #expect(claim.status == .cancelled)
        #expect(claim.revision == 5)
        // Three points, not two — the API invents a `return` point. Every point is
        // `skipped` because the claim was cancelled before pickup.
        #expect(claim.routePoints.map(\._type) == [.source, .destination, ._return])
        #expect(claim.routePoints.allSatisfy { $0.visitStatus == .skipped })
        // The capture carries fields the reference never mentions (`taxi_offer`,
        // `droppof_point`, numeric `price_raw`, `corp_client_id`). Decoding must not care.
        #expect(claim.corpClientId == "00000000000000000000000000000000")
    }

    @Test("A claim carrying packages and a robot handover status decodes")
    func decodesPackagesAndHandoverStatus() async throws {
        // `packages`, `performer_cancel_reasons` and `handover_status` are documented on
        // `V2ClaimInfo`/`V2ResponseCargoPoint` — the entity `claims/search` and
        // `claims/info` share — but no captured claim carried them yet. This fixture is
        // document-shaped for exactly that reason, pinned so the fields stay reachable.
        let json = Fixture.searchClaimsResponseJSON
            .replacingOccurrences(
                of: #""visit_status": "skipped""#,
                with: #"""
                    "visit_status": "skipped",
                    "handover_status": "completed"
                    """#
            )
            .replacingOccurrences(
                of: #""current_point_id": 17594193737507"#,
                with: #"""
                    "current_point_id": 17594193737507,
                    "packages": [
                      {
                        "package_id": "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c",
                        "package_type": "other",
                        "package_code": "ab10702030/?",
                        "pickup_point": 17594193737507,
                        "dropoff_point": 17594193737508
                      }
                    ],
                    "performer_cancel_reasons": ["example"]
                    """#
            )
        let client = try Client.stubbed(json: json)

        let response = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCursor(.init(cursor: "opaque")))
        )

        let claim = try #require(try? response.ok.body.json.claims.first)
        #expect(claim.routePoints.first?.handoverStatus == .completed)
        let package = try #require(claim.packages?.first)
        #expect(package.packageId == "a8e5b0e6-3d67-4d6f-89a5-3b6c1a0e4f5c")
        #expect(package.packageType == .other)
        #expect(package.pickupPoint == 17_594_193_737_507)
        #expect(claim.performerCancelReasons == ["example"])
    }

    // MARK: Search — encoding

    @Test("Search sends Accept-Language and encodes the filter variant")
    func searchEncodesFilterVariant() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.searchClaimsResponseJSON)

        _ = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCorp(.init(
                limit: 10,
                claimId: "01a0cd38be93807496944ebfc9654d02",
                createdFrom: Date(timeIntervalSince1970: 1_790_148_600),
                externalOrderId: "100",
                state: .finished,
                status: .cancelled
            )))
        )

        let request = try #require(await recorder.request)
        #expect(request.method == .post)
        #expect(request.path == "/claims/search")
        #expect(request.headerFields[.acceptLanguage] == "ru")

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        #expect(json["limit"] as? Int == 10)
        #expect(json["claim_id"] as? String == "01a0cd38be93807496944ebfc9654d02")
        #expect(json["state"] as? String == "finished")
        #expect(json["status"] as? String == "cancelled")
        #expect(json["external_order_id"] as? String == "100")
        #expect(json["created_from"] as? String == "2026-09-23T07:30:00.000Z")
        // Fields that were not set must not be sent — the wire treats a body matching
        // neither variant as a 400 ("cannot be parsed as a variant").
        #expect(json["cursor"] == nil)
        #expect(json["due_from"] == nil)
    }

    @Test("Search encodes the cursor variant — the continuation form")
    func searchEncodesCursorVariant() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.searchClaimsResponseJSON)

        _ = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCursor(.init(cursor: "opaque-search-cursor")))
        )

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        #expect(json["cursor"] as? String == "opaque-search-cursor")
        #expect(json.count == 1)
    }

    @Test("A search response cursor feeds straight into the next request")
    func searchCursorRoundTripsOpaque() async throws {
        // The whole pagination contract: response.cursor → next request's cursor, verbatim.
        // Both are opaque on the wire (a base64 JSON filter), which is why they are strings.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.searchClaimsResponseJSON)

        let first = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCorp(.init(limit: 1, claimId: "01a0cd38be93807496944ebfc9654d02")))
        )
        let page = try #require(try? first.ok.body.json)
        let cursor = try #require(page.cursor)

        _ = try await client.searchClaims(
            headers: .init(acceptLanguage: .ru),
            body: .json(.SearchClaimsRequestCursor(.init(cursor: cursor)))
        )

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        #expect(json["cursor"] as? String == cursor)
    }
}

import Foundation
import OpenAPIRuntime
import Testing
@testable import YandexDeliveryExpressAPI

/// Does the generated client decode what `openapi.yaml` says Yandex returns?
///
/// These are what make the hand-authored document falsifiable offline. A failure here means
/// the document and the client disagree; a failure of the same claim in the `Live API` suite
/// means the document and Yandex disagree. See the `SpecOwnership` article.
@Suite("Claim decoding", .tags(.specContract))
struct ClaimDecodingTests {
    @Test("An offers/calculate 200 decodes, dates included")
    func decodesOffersCalculateResponse() async throws {
        let client = try Client.stubbed(json: Fixture.offersCalculateResponseJSON)

        let response = try await client.calculateOffers(.sample)

        let offers = try #require(try? response.ok.body.json.offers)
        #expect(!offers.isEmpty)
        let offer = try #require(offers.first)
        #expect(offer.price.totalPriceWithVat == "807.6")
        #expect(offer.taxiClass == .express)
        #expect(offer.price.currency == .rub)
        // 2020-01-01T07:00:00+00:00. Epoch zero here would mean the transcoder swallowed a
        // parse failure rather than the date decoding.
        #expect(offer.deliveryInterval.from == Date(timeIntervalSince1970: 1_577_862_000))
        #expect(offer.pickupInterval.to == Date(timeIntervalSince1970: 1_577_905_200))
    }

    @Test("A claims/info 200 decodes, including timestamps of differing precision")
    func decodesClaimInfoResponse() async throws {
        let client = try Client.stubbed(json: Fixture.claimResponseJSON)

        let response = try await client.getClaimInfo(
            query: .init(claimId: "741cedf82cd464fa6fa16d87155c636"),
            headers: .init(acceptLanguage: .ru)
        )

        let claim = try #require(try? response.ok.body.json)
        #expect(claim.id == "741cedf82cd464fa6fa16d87155c636")
        #expect(claim.status == .readyForApproval)
        #expect(claim.version == 1)
        #expect(claim.routePoints.count == 2)
        #expect(claim.routePoints.first?._type == .source)
        #expect(claim.createdTs == Date(timeIntervalSince1970: 1_577_836_800))
        // The fixture's `updated_ts` carries six fraction digits and `created_ts` none.
        #expect(claim.updatedTs == Date(timeIntervalSince1970: 1_577_836_800.822))
    }

    @Test("A claims/cancel-info 200 decodes the state that decides whether cancelling costs money")
    func decodesClaimCancelInfoResponse() async throws {
        let client = try Client.stubbed(json: Fixture.claimCancelInfoResponseJSON)

        let response = try await client.getClaimCancelInfo(
            query: .init(claimId: "741cedf82cd464fa6fa16d87155c636"),
            headers: .init(acceptLanguage: .ru)
        )

        let info = try #require(try? response.ok.body.json)
        #expect(info.cancelState == .free)
        #expect(info.priceWithVat == "807.6")
    }

    @Test("The two cancel-state enums stay distinct")
    func cancelStateEnumsAreDistinct() {
        // `openapi.yaml` says so in as many words — «Не путать с CancelState» — and it
        // matters: `.unavailable` comes back from cancel-info and cannot be echoed into
        // cancelClaim, which has no such case. Pin both case sets so a future tidy-up
        // cannot merge them.
        #expect(Components.Schemas.CancelInfoCancelState.allCases.map(\.rawValue) == ["free", "paid", "unavailable"])
        #expect(Components.Schemas.CancelState.allCases.map(\.rawValue) == ["free", "paid"])
    }

    @Test("A documented non-2xx is a case to switch on, not a thrown error")
    func decodesDocumentedErrorBody() async throws {
        let client = try Client.stubbed(status: .unauthorized, json: Fixture.errorResponseJSON)

        let response = try await client.calculateOffers(.sample)

        guard case .unauthorized(let error) = response else {
            Issue.record("Expected .unauthorized, got \(response)")
            return
        }
        let body = try #require(try? error.body.json)
        #expect(body.code == "unauthorized")
        #expect(body.message == "Указан неверный токен")
    }

    @Test("An undocumented status arrives intact rather than as a failure")
    func reportsUndocumentedStatus() async throws {
        let client = try Client.stubbed(status: .init(code: 418), json: #"{"anything":true}"#)

        let response = try await client.calculateOffers(.sample)

        guard case .undocumented(let statusCode, _) = response else {
            Issue.record("Expected .undocumented, got \(response)")
            return
        }
        #expect(statusCode == 418)
    }

    @Test("An enum value Yandex might add tomorrow throws rather than decoding silently")
    func rejectsUnknownEnumValue() async throws {
        // Pins a real spec decision: these enums are closed. If this ever needs to pass
        // instead, the change belongs in `openapi.yaml` — mark the enum extensible — not
        // here. That is `SpecOwnership` working as designed.
        let json = Fixture.offersCalculateResponseJSON.replacingOccurrences(
            of: #""taxi_class": "express""#,
            with: #""taxi_class": "hyperloop""#
        )
        let client = try Client.stubbed(json: json)

        // A decoding failure is the *thrown* channel, not a documented-response case —
        // the two are not collapsed (see CLAUDE.md rule 8).
        await #expect(throws: ClientError.self) {
            _ = try await client.calculateOffers(.sample)
        }
    }
}

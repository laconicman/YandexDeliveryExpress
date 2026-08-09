import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The request side, which the decoding suite does not touch. Every assertion here is about
/// the bytes that actually leave the process, captured from `RecordingTransport` after the
/// middleware stack has run.
@Suite("Route point encoding", .tags(.specContract))
struct RoutePointEncodingTests {
    @Test("The allOf split does not reach the wire")
    func routePointWithAddressEncodesFlat() async throws {
        // The safety net for the `RoutePointWithAddress` flattening in `Roadmap` -> Next:
        // `value1` / `value2` is a generator artefact in the *Swift* surface only, and this
        // test must keep passing across that change. See `SpecOwnership` and TD-5.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder)

        _ = try await client.calculateOffers(.sample)

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        let routePoints = try #require(json["route_points"] as? [[String: Any]])
        let first = try #require(routePoints.first)

        #expect(first["id"] as? Int == 1)
        #expect(first["fullname"] as? String == "Москва, ул Москворечье, 6")
        #expect(first["value1"] == nil)
        #expect(first["value2"] == nil)
    }

    @Test("Property names encode as the wire keys the document declares")
    func encodesSnakeCaseWireKeys() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.claimResponseJSON)

        _ = try await client.createClaim(
            query: .init(requestId: "100000000000"),
            headers: .init(acceptLanguage: .ru),
            body: .json(.exampleSmartphoneDelivery)
        )

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        let routePoints = try #require(json["route_points"] as? [[String: Any]])
        let first = try #require(routePoints.first)

        #expect(first["point_id"] as? Int == 1)
        #expect(first["visit_order"] as? Int == 1)
        // `_type` in Swift, `type` on the wire — the leading underscore is the generator
        // avoiding a contextual keyword, not a rename. See `SpecOwnership`.
        #expect(first["type"] as? String == "source")
        #expect(first["pointId"] == nil)
    }

    @Test("Nil optionals are omitted rather than sent as null")
    func omitsNilOptionals() async throws {
        // The sample app relies on this to "save traffic", and Yandex rejects some nulls
        // it accepts as absent.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder)
        let request = Components.Schemas.OffersCalculateRequest(
            routePoints: .exampleMoscowRoute,
            requirements: .init()
        )

        _ = try await client.calculateOffers(headers: .init(acceptLanguage: .ru), body: .json(request))

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])

        #expect(json["items"] == nil)
        let requirements = try #require(json["requirements"] as? [String: Any])
        #expect(requirements.isEmpty)
    }
}

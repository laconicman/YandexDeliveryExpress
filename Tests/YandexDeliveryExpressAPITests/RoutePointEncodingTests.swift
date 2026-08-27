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

    @Test("The flat route point mirrors Address, field for field")
    func routePointStaysInSyncWithAddress() {
        // The TD-5 flattening left the mirror rule held together by comments alone: the
        // encoding test above asserts two fields, so a property added to `Address` and not
        // mirrored into the flat `RoutePointWithAddress` — or vice versa — would slip
        // through review. `Mirror` lists a struct's stored properties
        // (https://developer.apple.com/documentation/swift/mirror), so comparing the two
        // generated types pins the property sets mechanically; the wire keys stay pinned by
        // `encodesSnakeCaseWireKeys` and the test above.
        //
        // On the generator-internals dependency: both schemas are plain objects with no
        // `additionalProperties` keyword, and for that shape swift-openapi-generator emits
        // stored properties strictly 1:1 with the declared properties map — an
        // `additionalProperties` container is only ever generated when the keyword is
        // present (translateObjectStruct.swift / parseAdditionalProperties; verified against
        // upstream 2026-08-27,
        // https://deepwiki.com/search/for-a-plain-type-object-schema_8f81eb60-79af-44c5-b51b-f7661cbad2c2).
        // If a future generator breaks this, the failure is loud and names both field sets.
        let addressFields = Set(
            Mirror(reflecting: Components.Schemas.Address(fullname: "")).children.compactMap(\.label)
        )
        let routePointFields = Set(
            Mirror(reflecting: Components.Schemas.RoutePointWithAddress(id: 1, fullname: "")).children.compactMap(\.label)
        )
        #expect(routePointFields == addressFields.union(["id"]))
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

    @Test("A request timestamp goes out in the shape the document documents")
    func encodesRequestTimestamp() async throws {
        // The request side of the transcoder, which nothing else covers. `encode` now writes
        // fractional seconds — the fix for a lossy round trip — and that changed what
        // `OfferRequirements.due` looks like on the wire. If Yandex turns out to be strict
        // about this field, this is the test that says what we send.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder)
        // Exactly representable as a `Double`, so the expected string below is a fact about
        // our format style rather than about Foundation's rounding of the third digit.
        let due = Date(timeIntervalSince1970: 1_754_555_534.5)
        let request = Components.Schemas.OffersCalculateRequest(
            routePoints: .exampleMoscowRoute,
            requirements: .init(due: due)
        )

        _ = try await client.calculateOffers(headers: .init(acceptLanguage: .ru), body: .json(request))

        let body = try #require(await recorder.requestBody)
        let json = try #require(try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any])
        let requirements = try #require(json["requirements"] as? [String: Any])
        let encoded = try #require(requirements["due"] as? String)

        #expect(encoded == "2025-08-07T08:32:14.500Z")
        // And it survives the trip back, which is the point of writing the fraction at all.
        #expect(try FlexibleISO8601Transcoder().decode(encoded) == due)
    }

    @Test("A body-less POST carries no Content-Type")
    func bodylessOperationsSendNoContentType() async throws {
        // `getClaimInfo` and `getClaimCancelInfo` are POSTs with no request body, so the
        // generator sets no `Content-Type` for them. Deleting the middleware's global header
        // therefore changed these two operations and not the others — correct HTTP, but
        // nothing else offline would notice if it regressed in either direction.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, json: Fixture.claimResponseJSON)

        _ = try await client.getClaimInfo(
            query: .init(claimId: "741cedf82cd464fa6fa16d87155c636"),
            headers: .init(acceptLanguage: .ru)
        )

        let request = try #require(await recorder.request)
        #expect(request.method == .post)
        #expect(await recorder.requestBody == nil)
        #expect(request.headerFields[.contentType] == nil)
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

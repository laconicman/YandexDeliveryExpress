import Foundation
import HTTPTypes
import Testing
@testable import YandexDeliveryExpressAPI

/// `AuthMiddleware` sets one header. Three of these four tests pin things it must *not* do,
/// because each of them was in the shipped code and each failed silently.
@Suite("Auth middleware", .tags(.regression))
struct AuthMiddlewareTests {
    @Test("Sets the bearer Authorization header")
    func setsBearerAuthorizationHeader() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder, token: "s3cret")

        _ = try await client.calculateOffers(.sample)

        let request = try #require(await recorder.request)
        #expect(request.headerFields[.authorization] == "Bearer s3cret")
    }

    @Test("Leaves Content-Type to the generator")
    func doesNotOverrideContentType() async throws {
        // The middleware used to set `application/json` on every request regardless of
        // operation. The generator sets it per operation from the document — including the
        // `; charset=utf-8` this expectation would not see if the override came back.
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder)

        _ = try await client.calculateOffers(.sample)

        let request = try #require(await recorder.request)
        let contentType = try #require(request.headerFields[.contentType])
        #expect(contentType == "application/json; charset=utf-8")
    }

    @Test("Does not touch the path or its query")
    func doesNotMutateThePath() async throws {
        // Pins the deleted idempotency-key experiment, which appended a query parameter
        // derived from `HTTPBody.hashValue` — identity-based, so a retry of the same
        // request produced a different key (`Design`).
        let recorder = RequestRecorder()
        let client = try Client.recording(recorder: recorder)

        _ = try await client.calculateOffers(.sample)

        let request = try #require(await recorder.request)
        #expect(request.path == "/offers/calculate")
    }

    @Test("Passes the response through unmodified")
    func passesThroughResponseUnmodified() async throws {
        let recorder = RequestRecorder()
        let client = try Client.recording(
            recorder: recorder,
            json: Fixture.offersCalculateResponseJSON
        )

        let response = try await client.calculateOffers(.sample)

        let offers = try #require(try? response.ok.body.json.offers)
        #expect(offers.count == 1)
    }
}

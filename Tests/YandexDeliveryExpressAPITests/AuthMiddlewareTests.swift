import Foundation
import HTTPTypes
import OpenAPIRuntime
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

    @Test("A failure never puts the token in its error message")
    func errorsDoNotLeakTheCredential() async throws {
        // The live suites run with a real token, and a `ClientError` renders `request`
        // through `prettyDescription`, which prints **every header field verbatim** — so
        // whether the credential reaches a test log, a CI transcript or a bug report turns
        // entirely on *which* request object the runtime captured.
        //
        // Today it captures the one the serializer produced, before the middleware chain
        // runs, so the `Authorization` header is not in it. That is an implementation
        // detail of swift-openapi-runtime rather than a promise, and it is one upstream
        // could reasonably change while "improving" error diagnostics. Pin it: if this test
        // ever fails, stop running the live suites until it passes again.
        let token = "s3cret-token-that-must-not-appear-anywhere"
        let client = try Client(
            serverURL: try Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: FailingTransport(),
            middlewares: [AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(token)")]
        )

        do {
            _ = try await client.calculateOffers(.sample)
            Issue.record("Expected the transport to fail")
        } catch {
            let rendered = "\(error) \(String(describing: error)) \(error.localizedDescription)"
            #expect(!rendered.contains(token))
            #expect(!rendered.lowercased().contains("bearer"))
        }
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

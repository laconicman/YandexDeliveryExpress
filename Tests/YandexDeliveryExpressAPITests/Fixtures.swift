import Foundation
import HTTPTypes
import OpenAPIRuntime
@testable import YandexDeliveryExpressAPI

// MARK: - Transports

/// Returns a canned response without a network. Enough for every decoding test.
struct StubTransport: ClientTransport {
    let status: HTTPResponse.Status
    let json: String

    init(status: HTTPResponse.Status = .ok, json: String) {
        self.status = status
        self.json = json
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Captures what the middleware stack produced, then answers like `StubTransport`.
///
/// An `actor`, not a `nonisolated(unsafe) var`: the target is in Swift 6 language mode, and
/// the deleted YooMoneyAPIClient test file used the latter.
actor RequestRecorder {
    private(set) var request: HTTPRequest?
    private(set) var requestBody: String?

    func record(_ request: HTTPRequest, body: String?) {
        self.request = request
        self.requestBody = body
    }
}

struct RecordingTransport: ClientTransport {
    let recorder: RequestRecorder
    var status: HTTPResponse.Status = .ok
    var json: String = #"{"offers":[]}"#

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var text: String?
        if let body {
            text = try await String(collecting: body, upTo: .max)
        }
        await recorder.record(request, body: text)
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Fails the way a real network failure does, so the error that reaches the caller is a
/// `ClientError` carrying whatever context the runtime chose to attach.
struct FailingTransport: ClientTransport {
    struct Failure: Error {}

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw Failure()
    }
}

// MARK: - Clients under test

extension Client {
    /// A client wired to `StubTransport` through the **production** configuration, so a
    /// decoding test exercises the same `FlexibleISO8601Transcoder` a real call would.
    static func stubbed(status: HTTPResponse.Status = .ok, json: String) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: StubTransport(status: status, json: json)
        )
    }

    /// A client whose only middleware is `AuthMiddleware`, so the middleware suite sees
    /// exactly what it did and nothing else.
    static func recording(
        recorder: RequestRecorder,
        token: String = "test-token",
        json: String = #"{"offers":[]}"#
    ) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: RecordingTransport(recorder: recorder, json: json),
            middlewares: [AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(token)")]
        )
    }
}

// MARK: - Inputs

extension Operations.CalculateOffers.Input {
    static let sample = Self(
        headers: .init(acceptLanguage: .ru),
        body: .json(.exampleBasicRequest)
    )
}

// MARK: - Response fixtures
//
// Provenance, per fixture, because it decides what a failure means:
//
// - `offersCalculateResponseJSON` is **captured from the live API** (2026-08-12). A failure
//   against it means the client broke, not that the document is wrong.
// - Every other fixture is still derived from the `examples:` and `required:` blocks of
//   `openapi.yaml`, which cite Yandex's reference pages. Those prove the client decodes what
//   the document *claims*; only a live call proves the claim (TD-6). Replace each one with a
//   capture as evidence arrives, and say so here.
//
// The repository's other live-traffic record, `YandexDeliveryExpressDemo/Базовые запросы.postman_collection.json`,
// stores requests and no responses, which is why the document was the only source until now.

enum Fixture {
    /// `POST /offers/calculate` → 200. **Captured from the live API on 2026-08-12**, not
    /// derived from the document — the first real response this package has kept.
    ///
    /// Two offers out of five, chosen because they differ in a way no document-derived
    /// fixture would have: the first carries six-digit fractional seconds throughout, the
    /// second mixes them with timestamps that have **no fraction at all**, in the same
    /// `TimeInterval` object. The full response held 21 fractional and 4 plain stamps. That
    /// is TD-16 in one payload, and it is why the transcoder's reader must stay permissive.
    ///
    /// Note also `total_price: "1449"` — a monetary string with no decimal point, which the
    /// document's pattern permits and `Double.init?(wireDecimalString:)` accepts.
    ///
    /// The `payload` offer tokens are replaced with zeros: they are short-lived
    /// capability tokens for `createClaim` and there is no reason to keep real ones.
    static let offersCalculateResponseJSON = #"""
    {
      "offers": [
        {
          "price": {
            "total_price": "1449",
            "total_price_with_vat": "1767.78",
            "base_price": "1449",
            "surge_ratio": 2.963775,
            "currency": "RUB"
          },
          "taxi_class": "express",
          "pickup_interval": {
            "from": "2026-08-12T17:12:40.051944+00:00",
            "to": "2026-08-12T17:29:40.051944+00:00"
          },
          "delivery_interval": {
            "from": "2026-08-12T17:12:40.051944+00:00",
            "to": "2026-08-12T18:15:08.051944+00:00"
          },
          "description": "express",
          "payload": "offer-payload-redis/v1/00000000000000000000000000000000/1",
          "offer_ttl": "2026-08-12T17:22:40.051944+00:00"
        },
        {
          "price": {
            "total_price": "1139",
            "total_price_with_vat": "1389.58",
            "base_price": "1139",
            "surge_ratio": 2.329703,
            "currency": "RUB"
          },
          "taxi_class": "express",
          "pickup_interval": {
            "from": "2026-08-12T17:12:40.051944+00:00",
            "to": "2026-08-12T18:15:00+00:00"
          },
          "delivery_interval": {
            "from": "2026-08-12T17:12:40.051944+00:00",
            "to": "2026-08-12T19:15:00+00:00"
          },
          "description": "2_hours_delivery",
          "payload": "offer-payload-redis/v1/00000000000000000000000000000000/2",
          "offer_ttl": "2026-08-12T17:22:40.051944+00:00"
        }
      ]
    }
    """#

    /// `POST /claims/create` and `POST /claims/info` → 200. Shape from `ClaimResponse`.
    /// The two timestamps deliberately differ in fractional-second precision, which is the
    /// case `FlexibleISO8601Transcoder` exists for.
    static let claimResponseJSON = #"""
    {
      "created_ts": "2020-01-01T00:00:00+00:00",
      "updated_ts": "2020-01-01T00:00:00.500000+00:00",
      "id": "741cedf82cd464fa6fa16d87155c636",
      "revision": 1,
      "version": 1,
      "user_request_revision": "1",
      "status": "ready_for_approval",
      "items": [
        {
          "cost_currency": "RUB",
          "cost_value": "89990.00",
          "pickup_point": 1,
          "dropoff_point": 2,
          "quantity": 1,
          "title": "Смартфон"
        }
      ],
      "route_points": [
        {
          "id": 1,
          "address": { "fullname": "Москва, Красная площадь, 1" },
          "contact": { "name": "Иван Петров", "phone": "+79123456789" },
          "type": "source",
          "visit_order": 1,
          "visit_status": "pending",
          "visited_at": {}
        },
        {
          "id": 2,
          "address": { "fullname": "Санкт-Петербург, Большая Монетная улица, 1к1А" },
          "contact": { "name": "Анна Сидорова", "phone": "+79987654321" },
          "type": "destination",
          "visit_order": 2,
          "visit_status": "pending",
          "visited_at": {}
        }
      ]
    }
    """#

    /// `POST /claims/accept` → 200. Shape from `ClaimAcceptResponse`.
    static let claimAcceptResponseJSON = #"""
    {
      "id": "741cedf82cd464fa6fa16d87155c636",
      "skip_client_notify": false,
      "status": "accepted",
      "user_request_revision": "1",
      "version": 1
    }
    """#

    /// `POST /claims/cancel-info` → 200. Shape from `ClaimCancelInfoResponse`.
    static let claimCancelInfoResponseJSON = #"""
    {
      "cancel_state": "free",
      "currency": "RUB",
      "price": "807.6",
      "price_with_vat": "807.6"
    }
    """#

    /// `POST /claims/cancel` → 200. Shape from `ClaimCancelResponse`.
    static let claimCancelResponseJSON = #"""
    {
      "id": "741cedf82cd464fa6fa16d87155c636",
      "skip_client_notify": false,
      "status": "cancelled",
      "user_request_revision": "1",
      "version": 1
    }
    """#

    /// The `{code, message}` body every documented non-2xx shares. Shape and values from
    /// `ErrorResponse`.
    static let errorResponseJSON = #"""
    {
      "code": "unauthorized",
      "message": "Указан неверный токен"
    }
    """#
}

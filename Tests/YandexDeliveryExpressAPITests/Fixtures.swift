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
// Provenance: every field below is taken from the `examples:` and `required:` blocks of
// `Sources/YandexDeliveryExpressAPI/openapi.yaml`, which in turn cite the Yandex reference
// pages per schema. They are **not** captured live — the repository's only live-traffic
// record, `YandexDostavka/Базовые запросы.postman_collection.json`, stores requests and no
// responses. That is the honest limit of an offline suite: these tests prove the client
// decodes what the document claims, and only the `Live API` suite proves the claim
// (see the `SpecOwnership` and `TechDebt` articles, TD-6).

enum Fixture {
    /// `POST /offers/calculate` → 200. Shapes from `OffersCalculateResponse`,
    /// `CalculatedOffer`, `OfferPrice` and `TimeInterval`.
    static let offersCalculateResponseJSON = #"""
    {
      "offers": [
        {
          "delivery_interval": {
            "from": "2020-01-01T07:00:00+00:00",
            "to": "2020-01-01T19:00:00+00:00"
          },
          "pickup_interval": {
            "from": "2020-01-01T07:00:00+00:00",
            "to": "2020-01-01T19:00:00+00:00"
          },
          "payload": "5e2TPP5f7Yqyv19yRZ+QVas4JK+lhwa17ncxA3VCGI8hvnFS+CIySbmfHQlR6vhC2S4XsW+M7TbEV0EQl1/1Z0PO3QQX8KbGb6rtKay",
          "price": {
            "currency": "RUB",
            "surge_ratio": 1.1,
            "total_price": "673.0",
            "total_price_with_vat": "807.6",
            "base_price": "611.8"
          },
          "taxi_class": "express",
          "description": "express_30min_longer",
          "offer_ttl": "2020-01-02T00:00:00+00:00"
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

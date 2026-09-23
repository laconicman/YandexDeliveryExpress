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

    /// `POST /claims/journal` → 200. **Captured from the live API on 2026-09-23** — the four
    /// events of one test claim's create → estimate → ready_for_approval → cancel lifecycle,
    /// verbatim. Two things no document-derived fixture would have shown: the terminal event
    /// carries `resolution: "failed"` for a *user-initiated* cancel, and `revision` skips —
    /// `new` is revision 1, `estimating` is 3. The cursor was a signed JWT
    /// (`{version, last_known_id, holes}`); its signature is zeroed like the offer payloads
    /// above. The client must treat it as opaque either way.
    static let claimsJournalResponseJSON = #"""
    {
      "cursor": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ2ZXJzaW9uIjoxLCJsYXN0X2tub3duX2lkIjo4NywiaG9sZXMiOltdfQ.0000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      "events": [
        {
          "operation_id": 84,
          "claim_id": "01a0cd38be93807496944ebfc9654d02",
          "change_type": "status_changed",
          "updated_ts": "2026-09-23T07:44:03.849724+00:00",
          "new_status": "new",
          "revision": 1,
          "current_point_id": 17594193737507
        },
        {
          "operation_id": 85,
          "claim_id": "01a0cd38be93807496944ebfc9654d02",
          "change_type": "status_changed",
          "updated_ts": "2026-09-23T07:44:04.142087+00:00",
          "new_status": "estimating",
          "revision": 3,
          "current_point_id": 17594193737507
        },
        {
          "operation_id": 86,
          "claim_id": "01a0cd38be93807496944ebfc9654d02",
          "change_type": "status_changed",
          "updated_ts": "2026-09-23T07:44:04.402413+00:00",
          "new_status": "ready_for_approval",
          "revision": 4,
          "current_point_id": 17594193737507
        },
        {
          "operation_id": 87,
          "claim_id": "01a0cd38be93807496944ebfc9654d02",
          "change_type": "status_changed",
          "updated_ts": "2026-09-23T07:44:53.304895+00:00",
          "new_status": "cancelled",
          "resolution": "failed",
          "revision": 5,
          "current_point_id": 17594193737507
        }
      ]
    }
    """#

    /// `POST /claims/journal` → 200 with an empty page — the shape a first sync sees.
    /// Document-shaped (`{"cursor", "events": []}`), verified live 2026-09-23.
    static let claimsJournalEmptyJSON = #"""
    {
      "cursor": "opaque-journal-cursor",
      "events": []
    }
    """#

    /// `POST /claims/search` → 200. **Captured from the live API on 2026-09-23** — the same
    /// claim as the journal fixture, filtered by `claim_id`, cancelled and therefore with
    /// `visit_status: "skipped"` on every point. `corp_client_id` is zeroed — it is the
    /// account identifier and is never committed (see `WorkingWithYandex`).
    ///
    /// Deliberately kept verbatim beyond that: `droppof_point` next to `dropoff_point`, a
    /// top-level `taxi_offer` the reference does not document, a *numeric* `price_raw`
    /// inside it, and `warnings[].source: "taxi_requirements"`. Extra keys must keep
    /// decoding harmlessly — that tolerance is part of the contract this fixture pins.
    static let searchClaimsResponseJSON = #"""
    {
      "claims": [
        {
          "id": "01a0cd38be93807496944ebfc9654d02",
          "corp_client_id": "00000000000000000000000000000000",
          "items": [
            {
              "pickup_point": 17594193737507,
              "dropoff_point": 17594193737508,
              "droppof_point": 17594193737508,
              "title": "Документы",
              "weight": 0.3,
              "cost_value": "500.00",
              "cost_currency": "RUB",
              "quantity": 1,
              "age_restricted": false
            }
          ],
          "route_points": [
            {
              "id": 17594193737507,
              "contact": {
                "name": "Иван Петров",
                "phone": "+79123456789",
                "email": "ivan.petrov@example.com"
              },
              "address": {
                "fullname": "Москва, Красная площадь, 1",
                "shortname": "Красная площадь, 1",
                "coordinates": [37.6208, 55.7539],
                "country": "Россия",
                "city": "Москва",
                "street": "Красная площадь",
                "building": "1"
              },
              "type": "source",
              "visit_order": 1,
              "visit_status": "skipped",
              "skip_confirmation": false,
              "leave_under_door": false,
              "meet_outside": false,
              "no_door_call": false,
              "expected_visit_interval": {
                "from": "2026-09-23T07:44:03.700342+00:00",
                "to": "2026-09-23T08:01:03.700342+00:00"
              },
              "visited_at": {
                "actual": "2026-09-23T07:44:52.917869+00:00"
              }
            },
            {
              "id": 17594193737508,
              "contact": {
                "name": "Анна Сидорова",
                "phone": "+79987654321"
              },
              "address": {
                "fullname": "Москва, Тверская улица, 7",
                "shortname": "Тверская улица, 7",
                "coordinates": [37.6117, 55.7601],
                "country": "Россия",
                "city": "Москва",
                "street": "Тверская улица",
                "building": "7"
              },
              "type": "destination",
              "visit_order": 2,
              "visit_status": "skipped",
              "skip_confirmation": false,
              "leave_under_door": false,
              "meet_outside": false,
              "no_door_call": false,
              "expected_visit_interval": {
                "from": "2026-09-23T07:44:03.700342+00:00",
                "to": "2026-09-23T08:27:17.700342+00:00"
              },
              "visited_at": {
                "actual": "2026-09-23T07:44:52.917869+00:00"
              }
            },
            {
              "id": 17594193737509,
              "contact": {
                "name": "Иван Петров",
                "phone": "+79123456789",
                "email": "ivan.petrov@example.com"
              },
              "address": {
                "fullname": "Москва, Красная площадь, 1",
                "shortname": "Красная площадь, 1",
                "coordinates": [37.6208, 55.7539],
                "country": "Россия",
                "city": "Москва",
                "street": "Красная площадь",
                "building": "1"
              },
              "type": "return",
              "visit_order": 3,
              "visit_status": "skipped",
              "skip_confirmation": false,
              "leave_under_door": false,
              "meet_outside": false,
              "no_door_call": false,
              "visited_at": {
                "actual": "2026-09-23T07:44:52.917869+00:00"
              }
            }
          ],
          "current_point_id": 17594193737507,
          "status": "cancelled",
          "version": 1,
          "user_request_revision": "1",
          "error_messages": [],
          "skip_door_to_door": false,
          "skip_client_notify": false,
          "skip_emergency_notify": false,
          "skip_act": false,
          "optional_return": false,
          "eta": 10,
          "created_ts": "2026-09-23T07:44:03.349769+00:00",
          "updated_ts": "2026-09-23T07:44:52.917869+00:00",
          "last_status_change_ts": "2026-09-23T07:44:52.917869+00:00",
          "taxi_offer": {
            "offer_id": "cargo-pricing/v14/c101dc98-d331-410c-97fc-5245b4c8fcb7/pg-2/r-1",
            "price_raw": 404,
            "price": "492.8800"
          },
          "pricing": {
            "offer": {
              "offer_id": "cargo-pricing/v14/c101dc98-d331-410c-97fc-5245b4c8fcb7/pg-2/r-1",
              "price_raw": 404,
              "price": "492.8800",
              "valid_until": "2026-09-23T07:54:03.850248+00:00"
            },
            "currency": "RUB",
            "currency_rules": {
              "code": "RUB",
              "text": "RUB",
              "template": "RUB",
              "sign": "RUB"
            },
            "final_price": "0"
          },
          "client_requirements": {
            "taxi_class": "courier"
          },
          "matched_cars": [
            {
              "taxi_class": "courier",
              "door_to_door": true
            }
          ],
          "warnings": [
            {
              "source": "taxi_requirements",
              "code": "requirement_unavailable",
              "message": "Опция «Курьер Про» недоступна"
            }
          ],
          "revision": 5
        }
      ],
      "cursor": "eyJvZmZzZXQiOjAsImxpbWl0IjoxLCJjbGFpbV9pZCI6IjAxYTBjZDM4YmU5MzgwNzQ5Njk0NGViZmM5NjU0ZDAyIiwiY3JlYXRlZF90byI6IjIwMjYtMDktMjNUMDc6NDQ6MDMuMzQ5NzY5KzAwOjAwIn0="
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

import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession
import Testing
@testable import YandexDeliveryExpressAPI

// MARK: - Capturing the wire

/// One request/response pair, exactly as it crossed the wire.
struct WireExchange: Sendable {
    let operationID: String
    let statusCode: Int
    let requestBody: String?
    let responseBody: String?
}

/// Collects exchanges so a test can attach them after the fact.
actor WireLog {
    private(set) var exchanges: [WireExchange] = []
    func append(_ exchange: WireExchange) { exchanges.append(exchange) }

    /// The whole session as one attachable document.
    func transcript() -> String {
        exchanges.map { exchange in
            """
            ═══ \(exchange.operationID) → \(exchange.statusCode)
            ── request
            \(exchange.requestBody ?? "<no body>")
            ── response
            \(exchange.responseBody ?? "<no body>")
            """
        }
        .joined(separator: "\n\n")
    }
}

/// Wraps the real transport and records both directions verbatim.
///
/// Deliberately **not** a middleware: a middleware sees the request before the transport and
/// would also see the `Authorization` header this package is careful never to log. Sitting
/// below the middleware chain, this sees the body and the status and nothing secret.
struct CapturingTransport: ClientTransport {
    let log: WireLog
    private let inner = URLSessionTransport()

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var requestText: String?
        var forwardedBody = body
        if let body {
            let text = try await String(collecting: body, upTo: .max)
            requestText = text
            forwardedBody = HTTPBody(text)          // consumed above, so hand on a fresh one
        }

        let (response, responseBody) = try await inner.send(
            request,
            body: forwardedBody,
            baseURL: baseURL,
            operationID: operationID
        )

        var responseText: String?
        var forwardedResponse = responseBody
        if let responseBody {
            let text = try await String(collecting: responseBody, upTo: .max)
            responseText = text
            forwardedResponse = HTTPBody(text)
        }

        await log.append(
            WireExchange(
                operationID: operationID,
                statusCode: response.status.code,
                requestBody: requestText,
                responseBody: responseText
            )
        )
        return (response, forwardedResponse)
    }
}

extension Client {
    /// A live client that records every exchange. Same configuration and middleware as the
    /// production initializer, so what it captures is what a real caller sends.
    static func capturing(_ log: WireLog, credentials: Credentials) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: CapturingTransport(log: log),
            middlewares: [AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(credentials.authToken)")]
        )
    }
}

@Suite("The middleware slot")
struct MiddlewareSlotTests {
    /// A consumer middleware sits in the chain and sees the operation — and the
    /// authorized request, `Authorization` header included (TD-23). The probe
    /// short-circuits `next`, so no network is involved.
    @Test("An injected middleware sees the authorized request")
    func injectedMiddlewareSeesAuthorizedRequest() async throws {
        let probe = Probe()
        let client = try Client(
            credentials: Credentials(authToken: "s3cret"),
            middlewares: [ProbeMiddleware(probe: probe)]
        )

        _ = try await client.calculateOffers(.sample)

        #expect(await probe.operationID == "calculateOffers")
        #expect(await probe.authorization == "Bearer s3cret")
    }
}

private actor Probe {
    private(set) var operationID: String?
    private(set) var authorization: String?
    func record(operationID: String, authorization: String?) {
        self.operationID = operationID
        self.authorization = authorization
    }
}

private struct ProbeMiddleware: ClientMiddleware {
    let probe: Probe
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        await probe.record(
            operationID: operationID,
            authorization: request.headerFields[.authorization]
        )
        return (HTTPResponse(status: .ok), HTTPBody(#"{"offers":[]}"#))
    }
}

// MARK: - Drift detection

/// Compares what the API sent against what our generated types understand.
///
/// The trick is to avoid a hand-maintained list of "documented fields", which would drift from
/// `openapi.yaml` immediately. Instead: decode the response into the generated type, re-encode
/// it, and compare key paths.
///
/// - Keys in the raw payload but **not** in the round trip are fields Yandex sends and
///   `openapi.yaml` does not describe. That is a spec gap.
/// - Keys in the round trip but **not** in the raw payload are fields we invent — usually a
///   non-optional with a default, which is a spec defect in the other direction.
///
/// Neither is a test failure. Both are things a maintainer needs to see, so they are recorded
/// as warnings and attached.
enum WireDrift {
    /// Every key path in a JSON document, with array indices collapsed so `[0].id` and
    /// `[7].id` are the same path.
    static func keyPaths(of json: Any, prefix: String = "") -> Set<String> {
        switch json {
        case let object as [String: Any]:
            var paths: Set<String> = []
            for (key, value) in object {
                let path = prefix.isEmpty ? key : "\(prefix).\(key)"
                paths.insert(path)
                paths.formUnion(keyPaths(of: value, prefix: path))
            }
            return paths
        case let array as [Any]:
            return array.reduce(into: Set<String>()) { $0.formUnion(keyPaths(of: $1, prefix: "\(prefix)[]")) }
        default:
            return []
        }
    }

    static func keyPaths(ofJSONText text: String) -> Set<String> {
        guard let data = text.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data)
        else { return [] }
        return keyPaths(of: object)
    }

    /// Fields the API sent that our types do not model.
    static func undocumented<T: Encodable>(in rawText: String, understoodAs value: T) -> [String] {
        let encoder = JSONEncoder()
        guard let roundTripped = try? encoder.encode(value),
              let object = try? JSONSerialization.jsonObject(with: roundTripped)
        else { return [] }
        return keyPaths(ofJSONText: rawText).subtracting(keyPaths(of: object)).sorted()
    }

    /// A one-line census of the timestamp shapes in a payload — the TD-16 measurement.
    static func timestampShapes(in text: String) -> [String: Int] {
        var counts: [String: Int] = [:]
        // ISO-8601-ish: 2026-08-12T17:12:40[.051944][+00:00|Z]
        let pattern = #"20\d\d-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(Z|[+-]\d\d:?\d\d)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return counts }
        let range = NSRange(text.startIndex..., in: text)
        for match in regex.matches(in: text, range: range) {
            guard let stamp = Range(match.range, in: text).map({ String(text[$0]) }) else { continue }
            let fraction = stamp.contains(".")
                ? "fraction(\(stamp.split(separator: ".").last?.prefix(while: \.isNumber).count ?? 0) digits)"
                : "no fraction"
            // Classify from the *end* of the stamp rather than by slicing at a fixed index:
            // the date part contains `-` too, and a fraction shifts every offset's position.
            let zone: String
            if stamp.hasSuffix("Z") {
                zone = "Z"
            } else if let last = stamp.lastIndex(where: { $0 == "+" || $0 == "-" }),
                      stamp.distance(from: stamp.startIndex, to: last) > 10 {
                zone = "offset"
            } else {
                zone = "none"
            }
            counts["\(fraction), \(zone)", default: 0] += 1
        }
        return counts
    }
}

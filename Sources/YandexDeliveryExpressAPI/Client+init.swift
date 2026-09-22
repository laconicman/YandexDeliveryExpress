import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import Foundation
import OSLogLoggingMiddleware

public extension Client {
    /// A client authenticated with a Yandex Delivery OAuth token, logging through `OSLog`.
    ///
    /// - Parameters:
    ///   - serverURL: Defaults to the single server declared by the specification.
    ///   - credentials: The long-lived OAuth token issued from the Delivery profile.
    ///   - bodyLoggingConfiguration: Request bodies carry recipient names, phone numbers,
    ///     street addresses and door codes, so nothing is logged unless you opt in.
    init(
        serverURL: URL? = nil,
        credentials: Credentials,
        bodyLoggingConfiguration: BodyLoggingPolicy = .never
    ) throws {
        try self.init(
            serverURL: serverURL,
            credentials: credentials,
            middlewares: [OSLogLoggingMiddleware(bodyLoggingConfiguration: bodyLoggingConfiguration)]
        )
    }

    /// A client authenticated with a Yandex Delivery OAuth token, with the caller
    /// composing the rest of the middleware chain.
    ///
    /// - Parameters:
    ///   - serverURL: Defaults to the single server declared by the specification.
    ///   - credentials: The long-lived OAuth token issued from the Delivery profile.
    ///   - middlewares: The chain after authentication — an `OSLogLoggingMiddleware` for
    ///     the unified log, a wire-capture sink for TD-22's evidence, whatever the caller
    ///     composes. Each entry receives the *authorized* request, `Authorization`
    ///     header included; a sink must not persist headers (TD-23).
    init(
        serverURL: URL? = nil,
        credentials: Credentials,
        middlewares: [any ClientMiddleware]
    ) throws {
        self = Client(
            serverURL: try serverURL ?? Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: URLSessionTransport(),
            middlewares: [
                AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(credentials.authToken)")
            ] + middlewares
        )
    }
}

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
        self = Client(
            serverURL: try serverURL ?? Servers.Server1.url(),
            configuration: Configuration(dateTranscoder: FlexibleISO8601Transcoder()),
            transport: URLSessionTransport(),
            middlewares: [
                AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(credentials.authToken)"),
                OSLogLoggingMiddleware(bodyLoggingConfiguration: bodyLoggingConfiguration)
            ]
        )
    }
}

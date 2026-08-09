import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import Foundation
import OSLogLoggingMiddleware

public extension Client {
    init(serverURL: URL? = nil, credentials: Credentials, bodyLoggingConfiguration: BodyLoggingPolicy = .never) throws {
        let serverURL =  try serverURL ?? (Servers.Server1.url()) // Maybe spec server is used anyway.
        let configuration = Configuration(dateTranscoder: FlexibleISO8601Transcoder())
        let headerMiddleware = AuthMiddleware(authorizationHeaderFieldValue: "Bearer \(credentials.authToken)")
        let middlewares: [any ClientMiddleware]
        if #available(macOS 11.0, *) {
            middlewares = [headerMiddleware, OSLogLoggingMiddleware(bodyLoggingConfiguration: .upTo(maxBytes: 4000))]
        } else {
            // Fallback on earlier versions
            middlewares = [headerMiddleware]
        }
        self = Client(
            serverURL: serverURL,
            configuration: configuration,
            transport: URLSessionTransport(),
            middlewares: middlewares
        )
    }
}

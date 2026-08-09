import OpenAPIRuntime
import Foundation
import HTTPTypes

/// A client middleware that injects a value into header field of the request.
package struct AuthMiddleware { // This might want to be `public` someday.
    /// Header name to set
    private let httpFieldName: HTTPField.Name

    /// The value for the `httpFieldName` header field.
    private let value: String

    /// Creates a new middleware with convenience init.
    /// - Parameter authorizationHeaderFieldValue: The value for the `Authorization` header field.
    package init(authorizationHeaderFieldValue value: String) {
        self.httpFieldName = .authorization
        self.value = value
    }

    /// Creates a new middleware.
    /// - Parameter httpFieldName: The header field to set with `value`.
    /// - Parameter value: The value for the `httpFieldName` header field.
    package init(httpFieldName: HTTPField.Name = .authorization, value: String) {
        self.httpFieldName = httpFieldName
        self.value = value
    }

}

extension AuthMiddleware: ClientMiddleware {
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        // Sets the configured header field, and nothing else. `Content-Type` in particular
        // is the generator's to set, per operation, from the document.
        request.headerFields[httpFieldName] = value
        return try await next(request, body, baseURL)
    }
}

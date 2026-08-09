import Foundation

public struct Credentials: Sendable {
    public let authToken: String

    public init(authToken: String) {
        self.authToken = authToken
    }
}

public extension Credentials {
    /// Reads `AUTH_TOKEN` from the environment. `nil` when unset, so callers and tests can
    /// decide what that means. In Xcode, set it under Edit Scheme → Run → Environment.
    ///
    /// Keep the environment out of version control; this is a debugging convenience, not a
    /// credential store.
    static var environment: Self? {
        ProcessInfo.processInfo.environment["AUTH_TOKEN"].map(Self.init(authToken:))
    }
}

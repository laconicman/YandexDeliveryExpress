import Foundation

public struct Credentials: Sendable {
    public let authToken: String

    public init(authToken: String) {
        self.authToken = authToken
    }
}

public extension Credentials {
    /// Reads `AUTH_TOKEN` from the environment. `nil` when unset **or blank**, so callers and
    /// tests can decide what that means. In Xcode, set it under Edit Scheme → Run → Environment.
    ///
    /// Blank counts as unset because every live suite gates on `environment != nil`. With a
    /// plain `map`, `AUTH_TOKEN=""` produced a credential, switched the suites on, and failed
    /// them all as 401s instead of skipping — an empty variable is how a CI runner says "no
    /// token", not "this token".
    ///
    /// Keep the environment out of version control; this is a debugging convenience, not a
    /// credential store.
    static var environment: Self? {
        ProcessInfo.processInfo.environment["AUTH_TOKEN"]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .flatMap { $0.isEmpty ? nil : Self(authToken: $0) }
    }
}

import Foundation

public struct Credentials: Sendable {
    public let authToken: String
    
    public init(authToken: String) {
        self.authToken = authToken
    }
}

public extension Credentials {
    /// This is convenience var for debugging purposes. Make sure environment settings are gitignored and thus you won't leak credentials used during debug.
    static let fromEnvironment: Self = {
        guard let authToken = ProcessInfo.processInfo.environment["AUTH_TOKEN"] else {
            fatalError("AUTH_TOKEN environment variable is not set. You can set it with `Edit scheme`.")
        }
        return .init(authToken: authToken)
    }()
}

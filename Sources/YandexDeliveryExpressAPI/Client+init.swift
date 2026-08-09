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
    
    /// Reusable formatter to perform API specific conversions of `Double` often expressed as `String` throughout API.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static let floatingPointFormatStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
        .decimalSeparator(strategy: .automatic)
        .grouping(.never)
        .precision(.fractionLength(0...2))
   
}

public extension String {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var double: Double {
        (try? Double(self, format: Client.floatingPointFormatStyle)) ?? 0.0
    }
}

public extension Double {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var string: String {
        formatted(Client.floatingPointFormatStyle)
    }
}
/*
struct LenientISO8601Transcoder: DateTranscoder {

//  // Fast path on modern OSes (iOS 15+/macOS 12+)
//  @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
//    private static let v15 = Date.ISO8601FormatStyle(timeZone: .gmt)
//      .time(includingFractionalSeconds: true) // micro-/nanoseconds
//      .timeZone(separator: .colon)             // ±hh:mm

    // Fallback formatters for older systems
    private static let withMicroseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        return formatter
    }()

    private static let withoutFractional: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()

    private static let zFormatWithMicroseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return formatter
    }()

    private static let zFormatWithoutFractional: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()

    func decode(_ dateString: String) throws -> Date {
        
        // Try formatters in order of likelihood
        // 1. With microseconds and +00:00 offset
        if let date = Self.withMicroseconds.date(from: dateString) {
            return date
        }
        
        // 2. Without fractional seconds and +00:00 offset
        if let date = Self.withoutFractional.date(from: dateString) {
            return date
        }
        
        // 3. With microseconds and Z suffix
        if let date = Self.zFormatWithMicroseconds.date(from: dateString) {
            return date
        }
        
        // 4. Without fractional seconds and Z suffix
        if let date = Self.zFormatWithoutFractional.date(from: dateString) {
            return date
        }
        
        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Unable to parse ISO-8601 date: \(dateString)")
        )
    }

    func encode(_ date: Date) throws -> String {
        // Always output without microseconds and extended offset format
        return Self.withoutFractional.string(from: date)
    }

}
*/

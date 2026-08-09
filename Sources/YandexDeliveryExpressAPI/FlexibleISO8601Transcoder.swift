//
//  File.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/23/25.
//

import OpenAPIRuntime
import Foundation

struct FlexibleISO8601Transcoder: DateTranscoder {
    private static let gmt = TimeZone(secondsFromGMT: 0)!
    // iOS 15+ compatible formatter
    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    private static let modernFormatter: Date.ISO8601FormatStyle = {
        var formatter = Date.ISO8601FormatStyle()
        formatter.timeZone = gmt
        return formatter
            .time(includingFractionalSeconds: true)
            .timeZone(separator: .colon)
    }()
    
    // Fallback formatters for older systems...
    private static let withMicroseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = gmt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        return formatter
    }()
    
    private static let withoutFractional: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = gmt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
    
    func decode(_ dateString: String) throws -> Date {
        // Try modern API first (iOS 15+)
        if #available(iOS 15, macOS 12, watchOS 8, tvOS 15, *) {
            if let date = try? Self.modernFormatter.parse(dateString) {
                return date
            }
        }
        
        // Try formatters in order of likelihood
        if let date = Self.withMicroseconds.date(from: dateString) {
            return date
        }
        
        if let date = Self.withoutFractional.date(from: dateString) {
            return date
        }
        
        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Unable to parse ISO-8601 date: \(dateString)")
        )
    }
    
    func encode(_ date: Date) throws -> String {
        return Self.withoutFractional.string(from: date)
    }
}

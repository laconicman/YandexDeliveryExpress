//
//  FlexibleISO8601Transcoder.swift
//  YandexDeliveryExpressAPI
//
//  Created by Paul Buktab on 7/23/25.
//

import OpenAPIRuntime
import Foundation

/// Reads the ISO-8601 shapes the Express API emits, which differ in whether they carry
/// fractional seconds, and writes timestamps without discarding sub-second precision.
///
/// Every shape this type is expected to read is pinned by an argument of
/// `DateTranscoderTests.parsesWireTimestamp`, each cited to where it was observed. A shape
/// with no argument backing it is not supported here on purpose.
struct FlexibleISO8601Transcoder: DateTranscoder {
    private static let withFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
    private static let withoutFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: false, timeZone: .gmt)

    func decode(_ dateString: String) throws -> Date {
        if let date = try? Self.withFractionalSeconds.parse(dateString) {
            return date
        }

        if let date = try? Self.withoutFractionalSeconds.parse(dateString) {
            return date
        }

        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Unable to parse ISO-8601 date: \(dateString)")
        )
    }

    /// Writes fractional seconds. Omitting them — which this type used to do
    /// unconditionally — made `decode(encode(date))` lossy for any `Date` carrying
    /// sub-second precision.
    func encode(_ date: Date) throws -> String {
        Self.withFractionalSeconds.format(date)
    }
}

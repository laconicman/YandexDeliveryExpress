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

    /// Writes fractional seconds, to **millisecond** granularity — three digits is what
    /// `Date.ISO8601FormatStyle` emits.
    ///
    /// That is a narrower promise than "lossless", and the difference matters: a `Date`
    /// captured at runtime carries microseconds, and those are still dropped, so
    /// `decode(encode(date)) == date` holds only for values whose sub-second part is a whole
    /// number of milliseconds. What this fixes is the previous behaviour of dropping the
    /// fraction *entirely*, which lost up to a second. The remaining limit is pinned by
    /// `DateTranscoderTests.roundTripsWithoutLosingPrecision` rather than left to be
    /// rediscovered.
    func encode(_ date: Date) throws -> String {
        Self.withFractionalSeconds.format(date)
    }
}

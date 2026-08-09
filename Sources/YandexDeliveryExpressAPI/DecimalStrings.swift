//
//  DecimalStrings.swift
//  YandexDeliveryExpressAPI
//
//  The API expresses money and dimensions as decimal strings. One format style, and the
//  two conversions that use it, live together here rather than on the network client.
//

import Foundation

public extension Client {
    /// Reusable formatter to perform API specific conversions of `Double` often expressed as `String` throughout API.
    static let floatingPointFormatStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
        .decimalSeparator(strategy: .automatic)
        .grouping(.never)
        .precision(.fractionLength(0...2))
}

public extension String {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    var double: Double {
        (try? Double(self, format: Client.floatingPointFormatStyle)) ?? 0.0
    }
}

public extension Double {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    var string: String {
        formatted(Client.floatingPointFormatStyle)
    }
}

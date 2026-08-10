//
//  DecimalStrings.swift
//  YandexDeliveryExpressAPI
//

import Foundation

/// The shape `openapi.yaml` pins every monetary string to — `OfferPrice.total_price`,
/// `CargoItem.cost_value`, `ClaimPricing.final_price` and the rest all carry
/// `pattern: '^-?[0-9]{1,14}(\.[0-9]{0,4})?$'`.
///
/// Validating against the document rather than against a formatter is the point: we own the
/// document, so it is the definition of a well-formed amount, and anything else is a
/// response the specification did not predict.
///
/// Spelled out rather than written as a `Regex`, because a `Regex` is not `Sendable` and so
/// cannot be a global constant in Swift 6 language mode, and rebuilding one per amount to
/// work around that costs more than the twelve lines below.
private func isWireDecimal(_ string: String) -> Bool {
    func isDigits(_ characters: Substring) -> Bool {
        characters.allSatisfy { $0.isASCII && $0.isNumber }
    }

    let unsigned = string.first == "-" ? string.dropFirst() : Substring(string)
    let parts = unsigned.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
    guard let integer = parts.first, (1...14).contains(integer.count), isDigits(integer) else {
        return false
    }
    guard parts.count == 2 else { return true }
    return parts[1].count <= 4 && isDigits(parts[1])
}

/// How amounts are written: a dot separator, no grouping, at most two fraction digits.
/// Pinned to `en_US` so a device in a comma-decimal locale cannot emit `"807,6"` and have
/// the API reject it.
private let wireDecimalStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
    .decimalSeparator(strategy: .automatic)
    .grouping(.never)
    .precision(.fractionLength(0...2))

public extension Double {
    /// Reads one of the decimal strings the API uses in place of a number.
    ///
    /// `nil` unless the whole string is an amount the document permits. That strictness is
    /// deliberate: `Double("807,6", format:)` parses the digits before the comma and returns
    /// `807`, so a lenient reading turns a malformed price into a plausible wrong one.
    ///
    /// ```swift
    /// let total = Double(wireDecimalString: offer.price.totalPriceWithVat)
    /// ```
    init?(wireDecimalString string: String) {
        // `Double.init(_: String)` is locale-independent and exact; the pattern is what
        // decides whether the string was an amount in the first place.
        guard isWireDecimal(string), let value = Double(string) else { return nil }
        self = value
    }

    /// This value in the decimal string form the API expects.
    var wireDecimalString: String {
        formatted(wireDecimalStyle)
    }
}

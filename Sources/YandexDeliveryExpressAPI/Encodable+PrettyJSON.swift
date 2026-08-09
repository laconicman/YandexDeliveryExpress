//
//  Encodable+PrettyJSON.swift
//  YandexDeliveryExpressAPI
//

import Foundation

extension Encodable {
    /// One home for "render a generated type for a human".
    ///
    /// The operation outputs differ only in which cases exist; what a caller wants to see in
    /// each of them is the decoded body, and JSON is a better answer than a bespoke switch
    /// per schema. Deliberately not `public`: this exists so `description` has something to
    /// return, not to add a member to every `Encodable` in every consuming app.
    var prettyJSON: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        // The generated schemas carry `Date`s; the default numeric encoding would print
        // them as seconds since the reference date, which no reader can use.
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8)
        else { return String(localized: "Could not encode response", bundle: #bundle, comment: "Error description") }
        return string
    }
}

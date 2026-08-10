import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The API expresses money as strings, so these conversions sit between every price the
/// caller reads and every amount it sends.
@Suite("Decimal strings", .tags(.specContract))
struct DecimalStringTests {
    @Test(
        "Every amount shape the document permits parses",
        arguments: [
            ("807.6", 807.6),      // openapi.yaml OfferPrice.total_price_with_vat
            ("673.0", 673.0),      // openapi.yaml OfferPrice.total_price
            ("89990.00", 89990.0), // openapi.yaml CargoItem.cost_value — no grouping separator
            ("400.50", 400.5),     // openapi.yaml ClaimPricing.final_price
            ("0", 0.0),
            ("-1.25", -1.25),      // the pattern allows a leading minus
        ]
    )
    func parsesWireAmount(_ raw: String, _ expected: Double) throws {
        let value = try #require(Double(wireDecimalString: raw))

        #expect(value == expected)
    }

    @Test(
        "A string that is not an amount is nil — never a plausible wrong number",
        arguments: [
            "",
            "not a number",
            "807,6",            // comma-decimal locale output; parsed leniently it reads 807
            "1 234.5",          // grouped with a space; parsed leniently it reads 1
            "1,234.5",          // grouped with a comma
            "8.12345",          // five fraction digits — more than the pattern allows
            "9999999999999999", // sixteen integer digits — more than the pattern allows
            "1e5",
            "807.6 RUB",
        ]
    )
    func rejectsNonAmounts(_ raw: String) {
        // Two regressions in one. The previous spelling returned `0.0` for anything it could
        // not read, so a malformed price silently became free delivery. And a *lenient*
        // reading is worse still: `Double("807,6", format: style)` returns 807 — the digits
        // before the separator — which is not obviously wrong to anyone reading a log.
        #expect(Double(wireDecimalString: raw) == nil)
    }

    @Test("Amounts are written with a dot and no grouping, whatever the device locale is")
    func writesWireFormat() {
        #expect((1234.5).wireDecimalString == "1234.5")
        #expect((89990.0).wireDecimalString == "89990")
        #expect((0.5).wireDecimalString == "0.5")
        // Trailing zeros are dropped, so ordinary money is unaffected by the four-digit cap.
        #expect((807.60).wireDecimalString == "807.6")
    }

    @Test("Reader and writer accept the same set")
    func writerIsNotNarrowerThanReader() throws {
        // The document permits four fraction digits. When the writer capped at two, this
        // amount read back exactly and then wrote out as "12.35" — a silently different
        // number. Reader and writer must agree, or a round trip is lossy inside the
        // contract.
        let amount = try #require(Double(wireDecimalString: "12.3456"))

        #expect(amount == 12.3456)
        #expect(amount.wireDecimalString == "12.3456")
    }

    @Test("An amount survives a round trip")
    func roundTripsAmounts() throws {
        for amount in [0.0, 0.5, 807.6, 89990.0, -1.25, 12.3456, 0.0001] {
            let text = amount.wireDecimalString
            #expect(Double(wireDecimalString: text) == amount, "round trip of \(amount) via \"\(text)\"")
        }
    }
}

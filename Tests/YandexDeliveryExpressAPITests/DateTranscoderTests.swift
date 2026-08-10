import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// `FlexibleISO8601Transcoder` exists because Yandex is inconsistent about fractional
/// seconds. Each argument below is a shape the API is documented or recorded to emit; a
/// parse path with no argument backing it is dead code and should be deleted rather than
/// kept "just in case" (`Design`).
@Suite("Date transcoding", .tags(.specContract))
struct DateTranscoderTests {
    @Test(
        "Every timestamp shape the API emits parses to the right instant",
        arguments: [
            // `openapi.yaml` `TimeInterval.from`, transcribed from the Yandex reference page
            // for IntegrationV2OfferCalculate.
            ("2020-01-01T07:00:00+00:00", 1_577_862_000.0),
            // `openapi.yaml` `CalculatedOffer.offer_ttl`, same source.
            ("2020-01-02T00:00:00+00:00", 1_577_923_200.0),
            // Six fraction digits with a non-UTC offset, and the Zulu spelling. Recorded as
            // observed in `Test-Plan.md`; no captured response for either survives in this
            // repository, so the live suite is what re-confirms them.
            ("2026-08-07T10:32:14.822000+03:00", 1_786_087_934.822),
            ("2026-08-07T07:32:14Z", 1_786_087_934.0),
        ]
    )
    func parsesWireTimestamp(_ raw: String, _ expected: TimeInterval) throws {
        let transcoder = FlexibleISO8601Transcoder()

        let date = try transcoder.decode(raw)

        // The instant, not merely "it did not throw" — `decode` already throws on failure, so
        // asserting non-failure asserts nothing. The value is what pins the part the design
        // admits it leans on: that these styles handle a `+03:00` offset when their own
        // default separator is omitted. The third and fourth arguments are the same instant
        // one second-fraction apart, expressed in different zones, so a parser that ignored
        // the offset would put them three hours apart and fail here.
        #expect(date.timeIntervalSince1970 == expected)
    }

    @Test("Encoding keeps milliseconds — and only milliseconds")
    func roundTripsWithoutLosingPrecision() throws {
        // Regression for the shipped bug: `encode(_:)` used a seconds-only formatter, so
        // `decode(encode(date))` silently truncated. Fix `encode`, never this expectation.
        //
        // `.5` rather than `.822` on purpose. `1_754_555_534.822` is not exactly
        // representable as a `Double`, so exact equality here would depend on Foundation
        // rounding `821.9997…` ms *up* — true today, but not a contract, and the same
        // undocumented-tolerance caveat the transcoder's design already carries. A value
        // that is exactly representable tests the property without the ULP lottery.
        let transcoder = FlexibleISO8601Transcoder()
        let date = Date(timeIntervalSince1970: 1_754_555_534.5)

        let encoded = try transcoder.encode(date)

        #expect(encoded == "2025-08-07T08:32:14.500Z")
        #expect(try transcoder.decode(encoded) == date)

        // The other half, pinned so the guarantee is not read as wider than it is:
        // `Date.ISO8601FormatStyle` emits exactly three fraction digits, so a `Date` with
        // microsecond precision — which is what `Date()` gives you — does *not* survive
        // exactly. The fix recovered the millisecond, not the microsecond.
        let microseconds = Date(timeIntervalSince1970: 1_754_555_534.123456)
        let roundTripped = try transcoder.decode(try transcoder.encode(microseconds))
        #expect(roundTripped != microseconds)
        #expect(abs(roundTripped.timeIntervalSince(microseconds)) < 0.001)
    }

    @Test("Unparseable input fails loudly")
    func throwsOnUnparseableInput() {
        // The alternative — returning `.distantPast` — is how a wrong timestamp reaches a
        // caller as a plausible-looking value.
        let transcoder = FlexibleISO8601Transcoder()

        #expect(throws: DecodingError.self) {
            _ = try transcoder.decode("not a date")
        }
    }
}

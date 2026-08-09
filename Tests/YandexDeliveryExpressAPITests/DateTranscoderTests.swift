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
        "Every timestamp shape the API emits parses",
        arguments: [
            // `openapi.yaml` `TimeInterval.from`, transcribed from the Yandex reference page
            // for IntegrationV2OfferCalculate.
            "2020-01-01T07:00:00+00:00",
            // `openapi.yaml` `CalculatedOffer.offer_ttl`, same source.
            "2020-01-02T00:00:00+00:00",
            // Six fraction digits with a non-UTC offset, and the Zulu spelling. Recorded as
            // observed in `Test-Plan.md`; no captured response for either survives in this
            // repository, so the live suite is what re-confirms them.
            "2026-08-07T10:32:14.822000+03:00",
            "2026-08-07T07:32:14Z",
        ]
    )
    func parsesWireTimestamp(_ raw: String) throws {
        let transcoder = FlexibleISO8601Transcoder()

        let date = try transcoder.decode(raw)

        #expect(date != Date(timeIntervalSince1970: 0))
    }

    @Test("Encoding a date does not discard its sub-second component")
    func roundTripsWithoutLosingPrecision() throws {
        // Regression for the shipped bug: `encode(_:)` used a seconds-only formatter, so
        // `decode(encode(date))` silently truncated. Fix `encode`, never this expectation.
        let transcoder = FlexibleISO8601Transcoder()
        let date = Date(timeIntervalSince1970: 1_754_555_534.822)

        let encoded = try transcoder.encode(date)

        #expect(encoded.contains(".822"))
        #expect(try transcoder.decode(encoded) == date)
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

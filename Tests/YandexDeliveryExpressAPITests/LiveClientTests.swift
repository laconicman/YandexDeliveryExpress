import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The read-only half of live validation — the only thing that checks a hand-authored
/// specification against the API it describes.
///
/// Offline suites prove the client decodes what `openapi.yaml` *claims*; these prove the
/// claim. They need `AUTH_TOKEN` and a Yandex Delivery account, so they run on a schedule
/// rather than on every push (`Roadmap` -> Next, TD-6).
///
/// Nothing here changes server-side state; the lifecycle that does lives in
/// ``LiveMutatingTests`` behind a second switch.
@Suite(
    "Live API",
    .tags(.live),
    .enabled(if: Credentials.environment != nil, "Set AUTH_TOKEN to run"),
    .timeLimit(.minutes(1)),
    .serialized
)
struct LiveClientTests {
    private func liveClient() throws -> Client {
        let credentials = try #require(Credentials.environment)
        return try Client(credentials: credentials)
    }

    @Test("A real Moscow route returns at least one priced offer")
    func calculatesOffersForARealRoute() async throws {
        // Read-only, so it costs nothing to run.
        let client = try liveClient()

        let response = try await client.calculateOffers(.sample)

        let offers = try #require(try? response.ok.body.json.offers)
        #expect(!offers.isEmpty)
        let offer = try #require(offers.first)
        // Through the strict reader on purpose: a live price that the document's own pattern
        // rejects is a spec bug, and this suite is the only thing that can catch one (TD-6).
        let total = try #require(
            Double(wireDecimalString: offer.price.totalPriceWithVat),
            "Live price \"\(offer.price.totalPriceWithVat)\" is not an amount openapi.yaml permits"
        )
        #expect(total > 0)
    }

    @Test("A request timestamp we send is one the API accepts")
    func acceptsAFractionalSecondTimestamp() async throws {
        // Half of TD-15, for *this operation only*. `calculateOffers` is read-only, so
        // sending a `due` costs nothing — and until this runs green, "requests now carry
        // fractional seconds" is a change nothing has validated.
        //
        // **This does not generalise.** The API uses different timestamp formats in
        // different operations, in both directions, so a `due` that `offers/calculate`
        // accepts says nothing about what `claims/create` wants. See TD-16.
        let client = try liveClient()
        let due = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        let request = Components.Schemas.OffersCalculateRequest(
            routePoints: .exampleMoscowRoute,
            items: .exampleSmallOrder,
            // No `cargoLoaders` — the express tariff refuses them with a 409, which is how
            // the sample data was found to be wrong in the first place.
            requirements: .init(due: due, proCourier: true, taxiClasses: [.express])
        )

        let response = try await client.calculateOffers(
            headers: .init(acceptLanguage: .ru),
            body: .json(request)
        )

        // A 400 here is the finding, not a flake: it means the fractional-second `due` we
        // now emit is not what this endpoint wants.
        if case .badRequest(let error) = response {
            Issue.record("`due` with fractional seconds was rejected: \((try? error.body.json.message) ?? "?")")
        }
        #expect((try? response.ok.body.json.offers) != nil)
    }

    @Test("Every read operation decodes, and records rather than fails when it does not")
    func decodeReviewSweep() async throws {
        // The highest-value live test for an owned specification: it turns "Yandex changed
        // something" into a report instead of a mystery. `.undocumented` in the wild is a
        // spec bug report (`SpecOwnership`).
        let client = try liveClient()

        await withKnownIssue("Live response did not match openapi.yaml", isIntermittent: true) {
            let response = try await client.calculateOffers(.sample)
            guard case .undocumented(let statusCode, let payload) = response else {
                _ = try response.ok.body.json
                return
            }
            Issue.record("Undocumented status \(statusCode): \(payload)")
        }

        // The discovery pair: both are read-only, and each is a `.undocumented` away from
        // being a spec bug report rather than a failure.
        await withKnownIssue("claims/journal did not match openapi.yaml", isIntermittent: true) {
            let response = try await client.getClaimsJournal(query: .init(limit: 10))
            guard case .undocumented(let statusCode, let payload) = response else {
                _ = try response.ok.body.json
                return
            }
            Issue.record("Undocumented status \(statusCode): \(payload)")
        }

        await withKnownIssue("claims/search did not match openapi.yaml", isIntermittent: true) {
            let response = try await client.searchClaims(
                headers: .init(acceptLanguage: .ru),
                body: .json(.SearchClaimsRequestCorp(.init(limit: 1)))
            )
            guard case .undocumented(let statusCode, let payload) = response else {
                _ = try response.ok.body.json
                return
            }
            Issue.record("Undocumented status \(statusCode): \(payload)")
        }
    }

}

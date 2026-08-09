import Foundation
import Testing
@testable import YandexDeliveryExpressAPI

/// The suite that would have caught TD-2: four `description` implementations were
/// `"\(self)"`, which interpolates `self`, which calls `description`.
///
/// A stack overflow crashes the test *runner* rather than failing a test, so the suite
/// carries a time limit: if termination ever regresses, this reports rather than hangs.
@Suite("Descriptions", .tags(.regression), .timeLimit(.minutes(1)))
struct DescriptionTests {
    /// The six operations, so `allCases` fails to compile rather than quietly under-covering
    /// when a seventh is added to `openapi.yaml`.
    enum OperationUnderTest: String, CaseIterable, Sendable {
        case calculateOffers, createClaim, getClaimInfo, acceptClaim, getClaimCancelInfo, cancelClaim
    }

    @Test("Every operation output's description terminates", arguments: OperationUnderTest.allCases)
    func outputDescriptionsTerminate(_ operation: OperationUnderTest) async throws {
        // Termination *is* the assertion; non-emptiness only guards against a `description`
        // that terminates by returning nothing useful.
        let description = try await description(of: operation)

        #expect(!description.isEmpty)
    }

    @Test("Description does not fall back to reflecting its own type", arguments: OperationUnderTest.allCases)
    func descriptionDoesNotEchoItsOwnType(_ operation: OperationUnderTest) async throws {
        // `"\(self)"` reached for `String(describing:)`'s reflection fallback, whose output
        // is littered with `Operations.…`. Seeing that again means the recursion is back.
        let description = try await description(of: operation)

        #expect(!description.contains("Operations."))
        #expect(!description.contains("YandexDeliveryExpressAPI."))
    }

    @Test("A documented error renders its message, not a JSON dump")
    func errorDescriptionsRenderTheMessage() async throws {
        let client = try Client.stubbed(status: .unauthorized, json: Fixture.errorResponseJSON)

        let response = try await client.calculateOffers(.sample)

        #expect(response.description == "Указан неверный токен")
    }

    @Test(
        "Localized strings resolve through the module bundle",
        .enabled(
            if: Bundle.module.localizations.contains("ru"),
            "The String Catalog is only compiled by Swift Build; a native `swift build` copies it uncompiled — see the Design article"
        )
    )
    func enumDescriptionsAreLocalized() throws {
        // The TD-3 regression test. Asserting the `ru` value is the point: a `Bundle.main`
        // lookup — the bug — cannot produce it, and asserting the `en` value would pass
        // simply because the key equals the English string.
        let path = try #require(Bundle.module.path(forResource: "ru", ofType: "lproj"))
        let russian = try #require(Bundle(path: path))

        #expect(String(localized: "Free", bundle: russian) == "бесплатная")
        #expect(String(localized: "Unknown error", bundle: russian) == "Неизвестная ошибка")
        // And the call site reads from the same bundle the catalog is in.
        #expect(Components.Schemas.CancelState.free.description == String(localized: "Free", bundle: .module))
    }

    // MARK: Helpers

    private func description(of operation: OperationUnderTest) async throws -> String {
        switch operation {
        case .calculateOffers:
            try await Client.stubbed(json: Fixture.offersCalculateResponseJSON)
                .calculateOffers(.sample)
                .description
        case .createClaim:
            try await Client.stubbed(json: Fixture.claimResponseJSON)
                .createClaim(
                    query: .init(requestId: "100000000000"),
                    headers: .init(acceptLanguage: .ru),
                    body: .json(.exampleSmartphoneDelivery)
                )
                .description
        case .getClaimInfo:
            try await Client.stubbed(json: Fixture.claimResponseJSON)
                .getClaimInfo(query: .init(claimId: claimId), headers: .init(acceptLanguage: .ru))
                .description
        case .acceptClaim:
            try await Client.stubbed(json: Fixture.claimAcceptResponseJSON)
                .acceptClaim(
                    query: .init(claimId: claimId),
                    headers: .init(acceptLanguage: .ru),
                    body: .json(.init(version: 1))
                )
                .description
        case .getClaimCancelInfo:
            try await Client.stubbed(json: Fixture.claimCancelInfoResponseJSON)
                .getClaimCancelInfo(query: .init(claimId: claimId), headers: .init(acceptLanguage: .ru))
                .description
        case .cancelClaim:
            try await Client.stubbed(json: Fixture.claimCancelResponseJSON)
                .cancelClaim(
                    query: .init(claimId: claimId),
                    headers: .init(acceptLanguage: .ru),
                    body: .json(.init(version: 1, cancelState: .free))
                )
                .description
        }
    }

    private let claimId = "741cedf82cd464fa6fa16d87155c636"
}

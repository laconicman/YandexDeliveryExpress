# YandexDeliveryExpressAPI

A Swift client for [Yandex Delivery's Express (B2B Cargo) API](https://yandex.com/support/delivery-profile/ru/api/express/openapi/),
generated with [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)
and exposed as-is, so every request the API accepts is expressible.

Requests go over [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession)
via [Swift OpenAPI URLSession Transport](https://github.com/apple/swift-openapi-urlsession).

> **Unofficial.** Yandex publishes neither a Swift SDK nor an OpenAPI document for this API —
> not even on request. `openapi.yaml` here was written by hand from the HTML reference and
> observed traffic, which makes it this package's greatest asset and its largest liability.
> See [Owning the Specification](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/SpecOwnership.md).

## Documentation

The rendered DocC catalog is authoritative for architecture and direction; when it and this
README disagree, believe the catalog. Build it with
`swift package generate-documentation --target YandexDeliveryExpressAPI`, or read the sources:

| Article | What it answers |
|---|---|
| [Design](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Design.md) | Every load-bearing decision, with the alternative that was rejected |
| [Owning the Specification](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/SpecOwnership.md) | Why `openapi.yaml` is hand-written, and what that obligates in return |
| [Working with the Yandex API](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/WorkingWithYandex.md) | What the API actually does, observed on the wire and dated |
| [Tech Debt](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/TechDebt.md) | Every compromise carried, what it costs, and what would retire it |
| [Roadmap](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md) | Planned work in priority order |

## Installation

```swift
.package(url: "https://github.com/laconicman/YandexDeliveryExpress", from: "0.1.0")
```

Requires Swift 6.1 or newer, and iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1.

> **If you build with SwiftPM directly, the package's user-facing strings are English only.**
> SwiftPM's native build system copies `Localizable.xcstrings` into the resource bundle without
> compiling it, so the `ru` translations are not in the artifact. Xcode — and
> `swift build --build-system swiftbuild` — compile it properly. This affects shipped behaviour,
> not just tests; it is Tech Debt TD-10.

## Coverage

Six operations, the full Express lifecycle:

| Method | Path | What it does |
|---|---|---|
| `calculateOffers` | `POST /offers/calculate` | Price and time windows for a route |
| `createClaim` | `POST /claims/create` | Create a delivery claim |
| `getClaimInfo` | `POST /claims/info` | Read a claim back |
| `acceptClaim` | `POST /claims/accept` | Confirm a claim |
| `getClaimCancelInfo` | `POST /claims/cancel-info` | Ask what cancelling would cost |
| `cancelClaim` | `POST /claims/cancel` | Cancel |

## Usage

```swift
import Foundation
import YandexDeliveryExpressAPI

let client = try Client(credentials: .init(authToken: "<OAuth token>"))

// Two points and one parcel. `RoutePointWithAddress` is flat: the point id sits beside
// the address fields, exactly as on the wire.
let route: [Components.Schemas.RoutePointWithAddress] = [
    .init(id: 1, fullname: "Москва, Красная площадь, 1"),
    .init(id: 2, fullname: "Москва, Арбат, 10")
]
let items: [Components.Schemas.ItemBase] = [
    .init(quantity: 1, pickupPoint: 1, dropoffPoint: 2, weight: 0.5)
]

let response = try await client.calculateOffers(
    headers: .init(acceptLanguage: .ru),
    body: .json(.init(routePoints: route, items: items))
)

switch response {
case .ok(let ok):
    for offer in try ok.body.json.offers {
        print(offer.taxiClass, offer.price.totalPriceWithVat, offer.deliveryInterval.to)
    }
case .badRequest, .unauthorized, .conflict, .tooManyRequests, .internalServerError:
    print(response)                             // renders the API's own `message`
case .undocumented(let statusCode, _):
    // The document is wrong. Please open an issue — see Owning the Specification.
    print("undocumented status \(statusCode)")
}
```

Every documented status is its own `switch` case, so a rejected claim cannot be mistaken for
an accepted one. Transport and decoding failures are the *other* channel — they are thrown
as `ClientError` and never collapsed into a response case.

Any `Output` also has a readable `description`: pretty-printed JSON for a success, the API's
own `message` for a documented error.

### `.conflict` is a domain refusal, not a transport problem

`409` means the request was well formed and the *domain* said no —
`estimating.too_many_loaders` for cargo loaders on the `express` tariff, `state_mismatch` for a
claim that has moved on. It reads like an error and behaves like validation, so handle it
alongside `.badRequest` rather than as a failure. It was undocumented by Yandex until a live
call returned it (Tech Debt TD-17).

Two more things about error bodies, learned the same way. `code` carries **two vocabularies** —
symbolic (`not_found`, `state_mismatch`) and the status as a string (`"400"`) — so do not switch
on it as an enumeration. And the full catalogue of what this API actually does, as opposed to
what any document says, is in
[Working with the Yandex API](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/WorkingWithYandex.md).

### Cancellation is a two-step protocol

`getClaimCancelInfo` reports whether cancelling is `free`, `paid` or `unavailable`, and the
state you echo back to `cancelClaim`. Calling `cancelClaim` without reading the cancel state
first is how you accidentally accept a charge. Note the two enums are deliberately different:
`cancelClaim` has no `unavailable`.

### Amounts

Prices are decimal strings on the wire, and the document pins them to
`^-?[0-9]{1,14}(\.[0-9]{0,4})?$`. `Double(wireDecimalString:)` reads one and
`Double.wireDecimalString` writes one, pinned to `en_US` so a comma-decimal device cannot
emit `"807,6"` and have the API reject it.

```swift
guard let total = Double(wireDecimalString: offer.price.totalPriceWithVat) else {
    // Not an amount the specification permits — worth reporting, not worth guessing at.
    return
}
```

The initializer is failable on purpose: the reading is strict, because a lenient one returns
`807` for `"807,6"` rather than failing, and a plausible wrong price is harder to notice than
a missing one.

### Credentials for debugging

`Credentials.environment` reads `AUTH_TOKEN` and returns `nil` when it is unset. In Xcode,
set it under Edit Scheme → Run → Environment. Keep it out of version control.

## Generated code

`Client.swift` and `Types.swift` are produced by the generator **build plugin** on every build and are never committed. Editing `openapi.yaml` is the whole
regeneration workflow — there is no command to run, and the reviewable diff is the diff of
the document itself.

```console
% swift build
```

Xcode asks once to trust the plugin. SwiftPM may report `openapi.yaml` and
`openapi-generator-config.yaml` as unhandled files; that is expected, because the plugin
finds them by scanning the target's sources.

Fix specification problems *in the document*, not in Swift. We own it, so a one-line edit
there is cheaper than a hand-written extension working around a generated shape — the
inverse of the sibling `YooMoneyAPIClient`, whose document is upstream and untouchable.

## Testing

```console
% swift test --skip "Live API"      # no network, no credentials — the CI default
% AUTH_TOKEN=… swift test           # adds the read-only live suite
```

The offline suites cover decoding, request encoding, the auth middleware, the date
transcoder, the decimal-string conversions and the `description` implementations against a
stub transport. `LiveClientTests` talks to the real API, self-skips without `AUTH_TOKEN`,
and is the only thing that validates a hand-authored document (Tech Debt, TD-6).

The full lifecycle — create, read, ask what cancelling costs, cancel — **creates a real
claim**, so it lives in its own suite behind a second switch and is meant to be run by hand
against test credentials:

```console
% AUTH_TOKEN=… YDE_ALLOW_MUTATING_LIVE_TESTS=1 swift test --filter "Live API (mutating)"
```

It cancels whatever it creates, including when an expectation fails part-way, and asserts
that the cancellation landed. `acceptClaim` is deliberately not exercised live: accepting
starts the real courier search and is what makes a cancellation billable.

One caveat worth knowing before you write a localization test: SwiftPM's native build system
copies `Resources/Localizable.xcstrings` into the resource bundle **without compiling it**,
so translations only exist in artifacts built by Swift Build — Xcode, or
`swift build --build-system swiftbuild`.

## License

Apache 2.0 — see [LICENSE](LICENSE). Unofficial and unaffiliated with Yandex.

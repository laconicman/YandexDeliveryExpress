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
| [Tech Debt](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/TechDebt.md) | Every compromise carried, what it costs, and what would retire it |
| [Roadmap](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md) | Planned work in priority order |

## Installation

```swift
.package(url: "https://github.com/laconicman/YandexDeliveryExpressAPI", from: "0.1.0")
```

Requires Swift 6.1 or newer, and iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1.

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

// Two points and one parcel. `RoutePointWithAddress` carries the point id alongside the
// address; the `value1` / `value2` split is a generator artefact scheduled for removal —
// see Tech Debt, TD-5.
let route: [Components.Schemas.RoutePointWithAddress] = [
    .init(value1: .init(id: 1), value2: .init(fullname: "Москва, Красная площадь, 1")),
    .init(value1: .init(id: 2), value2: .init(fullname: "Москва, Арбат, 10"))
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
case .badRequest, .unauthorized, .tooManyRequests, .internalServerError:
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

### Cancellation is a two-step protocol

`getClaimCancelInfo` reports whether cancelling is `free`, `paid` or `unavailable`, and the
state you echo back to `cancelClaim`. Calling `cancelClaim` without reading the cancel state
first is how you accidentally accept a charge. Note the two enums are deliberately different:
`cancelClaim` has no `unavailable`.

### Credentials for debugging

`Credentials.environment` reads `AUTH_TOKEN` and returns `nil` when it is unset. In Xcode,
set it under Edit Scheme → Run → Environment. Keep it out of version control.

## Generated code

`Client.swift`, `Types.swift` and `Server.swift` are produced by the generator **build
plugin** on every build and are never committed. Editing `openapi.yaml` is the whole
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
% AUTH_TOKEN=… swift test           # includes the live suite
```

The offline suites cover decoding, request encoding, the auth middleware and the date
transcoder against a stub transport. The live suite talks to the real API, self-skips
without `AUTH_TOKEN`, and is the only thing that validates a hand-authored document
(Tech Debt, TD-6).

One caveat worth knowing before you write a localization test: SwiftPM's native build system
copies `Resources/Localizable.xcstrings` into the resource bundle **without compiling it**,
so translations only exist in artifacts built by Swift Build — Xcode, or
`swift build --build-system swiftbuild`.

## License

Apache 2.0. See [LICENSE](LICENSE).

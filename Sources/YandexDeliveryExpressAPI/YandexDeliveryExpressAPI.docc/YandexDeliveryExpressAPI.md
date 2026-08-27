# ``YandexDeliveryExpressAPI``

A type-safe, async/await client for Yandex Delivery's Express (B2B Cargo) API, generated
from a hand-authored OpenAPI document with Apple's
[swift-openapi-generator](https://github.com/apple/swift-openapi-generator).

## Overview

Yandex publishes no OpenAPI document and no Swift SDK for this API. The document in this
package was written by reading Yandex's HTML reference and observing real traffic, which
makes it the load-bearing artifact here — see <doc:SpecOwnership>.

Six operations are covered, the full Express lifecycle:

| Operation | Path | What it does |
|---|---|---|
| `calculateOffers` | `POST /offers/calculate` | Price and time windows for a route |
| `createClaim` | `POST /claims/create` | Create a delivery claim |
| `getClaimInfo` | `POST /claims/info` | Read a claim back |
| `acceptClaim` | `POST /claims/accept` | Confirm a claim |
| `getClaimCancelInfo` | `POST /claims/cancel-info` | Ask what cancelling would cost |
| `cancelClaim` | `POST /claims/cancel` | Cancel |

```swift
import Foundation
import YandexDeliveryExpressAPI

let client = try Client(credentials: .init(authToken: "<OAuth token>"))

let response = try await client.calculateOffers(
    headers: .init(acceptLanguage: .ru),
    body: .json(.init(routePoints: route, items: items))
)

switch response {
case .ok(let ok):
    for offer in try ok.body.json.offers {
        print(offer.taxiClass, offer.price.totalPriceWithVat)
    }
case .badRequest, .unauthorized, .tooManyRequests, .internalServerError, .undocumented:
    break                       // each is a distinct, handleable case
}
```

Every documented status is its own `switch` case, so a rejected claim cannot be mistaken
for an accepted one. Anything the document does not describe arrives as `.undocumented`
rather than being silently swallowed.

### Authentication

The API takes a single `Authorization: Bearer <token>` header. ``Credentials`` carries the
token and an internal `AuthMiddleware` injects it. There is no refresh flow — the token is a
long-lived OAuth token issued from the Yandex Delivery profile.

### Cancellation is a two-step protocol

`getClaimCancelInfo` reports whether a cancellation is `free` or `paid` and returns the
state you must echo back to `cancelClaim`. Calling `cancelClaim` without first reading the
cancel state is how you accidentally accept a charge. The API models this; so does the
client.

## Topics

### Project Direction

- <doc:Design>
- <doc:SpecOwnership>
- <doc:WorkingWithYandex>
- <doc:TechDebt>
- <doc:Roadmap>
- <doc:Migration>

### Getting Started

- ``Credentials``

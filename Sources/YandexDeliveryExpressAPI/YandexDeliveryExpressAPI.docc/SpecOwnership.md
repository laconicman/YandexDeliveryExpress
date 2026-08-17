# Owning the Specification

Yandex publishes no OpenAPI document for the Express API. This one was written by hand, so
it is both the package's greatest asset and its largest liability.

## What "owned" buys

`Sources/YandexDeliveryExpressAPI/openapi.yaml` is the single source of truth for the Swift
API surface. Every naming and shape question that other generated clients solve with a
transform tool, a config override, or a hand-written extension is solved here with a
**one-line edit to the document**. That is the cheapest fix available and it should be the
first one considered.

Concretely, this is why the package has no `SpecSync`, no `nameOverrides` for operations,
and no `value1`/`value2` factory layer.

## What "owned" costs

Nobody validates the document against the real API but us. Yandex can change a response
shape and nothing fails until a request fails at runtime. Two obligations follow, and they
are the price of the whole approach:

1. **Every schema carries a provenance comment** — a link to the Yandex reference page it
   was read from, or a note that it was observed on the wire and never documented.
   `openapi.yaml` already does this in places (`# Manually checked`, the
   `RoutePointWithAddress` links); it needs to be uniform.
2. **The live test suite is the validator.** An offline stub suite proves the client decodes
   what we *say* the API returns; only the live suite proves we said the right thing. This
   inverts the usual priority — see <doc:TechDebt> item 6.

## Naming: shape the document, not the generated code

`openapi-generator-config.yaml` uses `namingStrategy: idiomatic`, which produces clean Swift
identifiers from clean OpenAPI identifiers. The document already carries good `operationId`s
(`calculateOffers`, `createClaim`, `getClaimInfo`, `acceptClaim`, `getClaimCancelInfo`,
`cancelClaim`), which is why the client methods read well.

**Do not reach for `nameOverrides` to rename an operation.** The generator returns an
override verbatim from *both* the type and member name positions, so a single string has to
serve `func capturePayment` and `enum Operations.CapturePayment` at once, and no string
satisfies both. An `operationId` runs each position through its own transform and has no
such problem. This is a known upstream behaviour, verified against `main` at `b2064e3f`
(2026-08-06); the full write-up lives in `YooMoneyAPIClient/Upstream/nameoverrides-verbatim-casing.md`.

`nameOverrides` **is** safe for *property* names, which only occupy the member position.
The one candidate here is the `type` property on `RoutePointBase`, which generates as
`_type` because `type` is contextually awkward in Swift. If that leading underscore is worth
removing:

```yaml
nameOverrides:
  type: kind        # NB: document-wide — currently affects 2 schemas
```

Weigh that against simply renaming the property in the document, which is not possible here
because `type` is the wire name Yandex sends.

## Flatten annotation-only `allOf` wrappers

The document contains exactly one `allOf`, on `RoutePointWithAddress`: an inline object
carrying `id` composed with a `$ref` to `Address`. The generator has no way to merge those
into one struct, so it emits a `value1`/`value2` pair — and that pair leaks all the way out
to callers:

```swift
// Today, in the sample app's CalculateOffersViewModel:
Components.Schemas.RoutePointWithAddress(
    value1: .init(id: $0.pointId),
    value2: $0.address
)
// And in Types+Identifiable.swift:
extension Components.Schemas.RoutePointWithAddress: Identifiable {
    public var id: Int64 { value1.id }
}
```

`value1`/`value2` is a generator implementation detail that has become part of this
package's public API. Upstream tracks the general problem as
[swift-openapi-generator#28](https://github.com/apple/swift-openapi-generator/issues/28)
(open since 2023, `status/needs-design`), so it will not be fixed for us.

Because we own the document, the fix is to write `RoutePointWithAddress` as a flat object
with `id` plus `Address`'s properties inlined, or to give `Address` an `id` and drop the
wrapper. Either removes `value1`/`value2` from the public surface, deletes the two call
sites above, and costs one edit. It is a **breaking change** to the package's API, which is
why it is scheduled rather than done silently — <doc:Roadmap>.

Do **not** hide it behind hand-written factory methods the way `YooMoneyAPIClient` has to.
That package cannot edit its document; this one can, and a factory that conceals a shape we
control is duplicated knowledge with a fixable root cause.

## Filtering is not needed

`openapi-generator-config.yaml` has no `filter:` block. Filter tiers exist to keep a
thousand-operation document from dominating build time; six operations do not. Adding a
filter here would be structure without a problem to solve.

## See Also

- <doc:Design>
- <doc:TechDebt>
- <doc:Roadmap>
- <doc:WorkingWithYandex>

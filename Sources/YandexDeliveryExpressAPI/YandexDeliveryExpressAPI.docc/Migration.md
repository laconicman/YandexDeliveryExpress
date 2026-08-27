# Migration

Source-breaking changes between released versions, and the mechanical fix for each. The wire
format is unchanged in every entry unless it says otherwise — these are Swift-surface
migrations, not behaviour changes.

## 0.1.0 → 0.2.0

### `RoutePointWithAddress` is flat

The annotation-only `allOf` behind `RoutePointWithAddress` generated a `value1`/`value2`
pair (TD-5). The schema is now a flat object declaring `id` beside the address fields, which
is what the wire always carried — `RoutePointEncodingTests.routePointWithAddressEncodesFlat`
pins that the bytes did not move.

```swift
// Before
Components.Schemas.RoutePointWithAddress(
    value1: .init(id: 1),
    value2: .init(fullname: "Москва, Красная площадь, 1")
)
route.value1.id       // reading the point id
route.value2.fullname // reading an address field

// After
Components.Schemas.RoutePointWithAddress(
    id: 1,
    fullname: "Москва, Красная площадь, 1"
)
route.id       // `Identifiable` now comes from the schema's own `id`
route.fullname
```

A caller holding an `Address` and an id no longer has a one-line bridge; copy the fields
across, or keep a private `init(id:address:)` like the one the test target uses
(`SampleData.swift`). If that bridge turns out to be what every caller writes, the package's
"convenience call shorthands" roadmap item is where it should land — tell us rather than
each app growing its own.

### `[RoutePointBase].newRoutePoint` / `.addRoutePoint` are gone

The unnamespaced `Array` extension invented point ids (`max + 1`) inside a transport
library (TD-13). Nothing replaces it: choosing an id is the caller's decision. If you used
it, the seventeen lines are in history at tag `0.1.0` — copy them into your app and own the
id policy explicitly.

## See Also

- <doc:TechDebt>
- <doc:SpecOwnership>

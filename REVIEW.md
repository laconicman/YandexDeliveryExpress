# Review Guidelines

Review-specific guidance. `CLAUDE.md` carries the standing rules and is ingested alongside
this file — nothing here restates it. These are the diff-level cues and the noise filters.

## Critical Areas

- `Sources/YandexDeliveryExpressAPI/openapi.yaml` is the API surface. Require any change to a
  schema's shape, required-ness, or enum values to cite provenance beside the edit — a Yandex
  reference link or a dated wire observation.
- Flag an edit to the `Address` schema in `Sources/YandexDeliveryExpressAPI/openapi.yaml`
  without the mirrored edit to the flat `RoutePointWithAddress`, and vice versa — the two are
  deliberate duplicates (TD-5), pinned by `routePointWithAddressEncodesFlat`.
- Flag any change to what the client sends — `encode` in
  `Sources/YandexDeliveryExpressAPI/FlexibleISO8601Transcoder.swift`, the writer in
  `Sources/YandexDeliveryExpressAPI/DecimalStrings.swift`, header behaviour in
  `Sources/YandexDeliveryExpressAPI/AuthMiddleware.swift` — that cites no live-call evidence.
  Symmetry or tidiness is not evidence.

## Conventions

- Reject hand-written Swift that reshapes or wraps a `Components.Schemas.*` type — the fix
  belongs in `Sources/YandexDeliveryExpressAPI/openapi.yaml` (TD-5 is the precedent).
- Reject committed generated code: a reappearing Sources/GeneratedSources/ directory, or a
  committed Client.swift / Types.swift (deliberately absent today — the build plugin owns
  them, so their appearance in a diff is itself the defect).
- Flag a status flip of a `TD-n` entry in
  `Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/TechDebt.md` that does not
  name what discharged it.
- Flag a new `// TODO` in `Sources/` that carries no `TD-n` register number.
- Require a new live test to carry the `Live API` suite prefix and gate on `AUTH_TOKEN`;
  require `YDE_ALLOW_MUTATING_LIVE_TESTS=1` as a second gate if it creates or mutates a claim.
- Flag a new closed `enum` on a response-side field whose content is advisory or descriptive
  prose — TD-19's boundary: enum where callers must branch, string where the field is prose.

## Anti-patterns to Flag

- Reject `description` implemented via `"\(self)"` or `String(describing: self)` in
  `Sources/YandexDeliveryExpressAPI/Types+CustomStringConvertible.swift` — infinite recursion
  on the success path; it shipped once (TD-2).
- Reject `String(localized:)` without `bundle: #bundle` anywhere in `Sources/` — it resolves
  against the consuming app's bundle and silently returns the key (TD-3).
- Reject any `@available` annotation in `Sources/` — the floor is iOS 17 / macOS 14; needing
  one means the API is above the floor or the code is in the wrong place.
- Reject middleware that sets `Content-Type` or synthesizes idempotency keys in
  `Sources/YandexDeliveryExpressAPI/AuthMiddleware.swift` — both were live defects.

## Security

- Flag any code path that logs a `Credentials` value or the `Authorization` header —
  `AuthMiddlewareTests` pins that a failure never carries the token.
- Flag any change moving the `bodyLoggingConfiguration` default off `.never` — request bodies
  carry names, phones, street addresses, and door codes.

## Ignore

- Skip `Package.resolved` — this package does not commit one; flag its *appearance* instead.
- Skip byte-level churn inside existing captures in
  `Tests/YandexDeliveryExpressAPITests/Fixtures.swift`, but require provenance (capture date
  or document link) on any new fixture.

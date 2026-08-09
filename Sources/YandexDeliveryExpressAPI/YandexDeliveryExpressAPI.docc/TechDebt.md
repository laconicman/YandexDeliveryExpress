# Tech Debt

Known compromises and defects carried by this package. Each entry names what it costs and
the change that discharges it. Reference an item from code with `// TODO(TD-n): …`.

Status legend: **open** (accepted for now) · **blocking** (must be fixed before the package
builds or ships) · **obligation** (permanent cost of a deliberate design choice).

## TD-1 — The package does not build — **blocking**

`Package.swift` declares target `YandexDeliveryExpressAPI` with no `path:`, so SwiftPM looks
for `Sources/YandexDeliveryExpressAPI/`. The sources are in
`Sources/YandexDeliveryExpressAPIClient/` and `Sources/GeneratedSources/`. The test target
`YandexDeliveryExpressAPITests` has the same mismatch against
`Tests/YandexDeliveryExpressAPIClientTests/`. Neither directory exists under the declared
name, and the generator plugin was never attached to the target at all.

- **Cost:** total. Nothing in this repository compiles.
- **Discharge:** rename the source directory to match the target, delete
  `Sources/GeneratedSources/`, and attach the build plugin. First item in the handoff.

## TD-2 — `CustomStringConvertible` recurses infinitely — **blocking**

Four extensions in `Types+CustomStringConvertable.swift` are written as:

```swift
extension Operations.CreateClaim.Output: CustomStringConvertible {
    public var description: String { "\(self)" }
}
```

String interpolation of a value calls `String(describing:)`, which prefers
`CustomStringConvertible` — so `description` calls `description`. This is a stack overflow,
not a formatting bug, and it fires on the **success** path of `createClaim`, `getClaimInfo`,
`acceptClaim` and `cancelClaim`. The sample app's `RequestState.log(_:)` takes
`T: CustomStringConvertible` and reads `.description`, so four of its five screens crash the
moment a request succeeds.

- **Cost:** four of six operations are unusable through the documented logging path.
- **Discharge:** implement the conformances properly — the file's own `TODO` already names
  the answer (`JSONEncoder` with `.prettyPrinted`, via `Encodable`), and
  `CalculateOffers.Output` shows the switch-per-case shape. Anything that cannot be
  implemented meaningfully should not conform at all. Pinned by a test that would have
  caught it (see the test plan).

## TD-3 — Localized strings resolve against the wrong bundle — **blocking**

`Types+CustomStringConvertable.swift` calls `String(localized:comment:)` with no `bundle:`
argument. In a Swift package that searches `Bundle.main` — the consuming app's bundle — the
lookup fails silently and the key is returned verbatim. `Package.swift` also declares
`defaultLocalization: "en"` while `Sources/Resources/` contains no String Catalog, so there
is nothing to resolve against in either bundle.

There is a second, smaller bug in the same file: the `.undocumented` case interpolates
`statusCode` but writes `Payload: payload` as literal text — the `payload` value is never
shown.

- **Cost:** every localized string in the package is a no-op; the Russian build shows English
  keys.
- **Discharge:** add `bundle: #bundle` to every call, create
  `Sources/YandexDeliveryExpressAPI/Resources/Localizable.xcstrings`, and declare it as a
  processed resource.

## TD-4 — The test target contains another package's tests — **blocking**

`Tests/YandexDeliveryExpressAPIClientTests/YandexDeliveryExpressAPIClientTests.swift` is a
verbatim copy of `YooMoneyAPIClient`'s XCTest suite: it declares `final class YooClientTests`,
does `@testable import YooMoneyAPI`, and tests payment creation and cancellation. There are
**zero** tests for this package.

- **Cost:** no regression signal of any kind, and a file that cannot compile.
- **Discharge:** delete it and write the suites in `Test-Plan.md`.

## TD-5 — `value1` / `value2` is public API — **open**

`RoutePointWithAddress` is an annotation-only `allOf`, so the generator emits a
`value1`/`value2` pair that callers must construct by hand. A generator implementation
detail is part of this package's surface. Full analysis in <doc:SpecOwnership>.

- **Cost:** the single worst-reading construct in the API, reproduced at every call site
  that builds a route point.
- **Discharge:** flatten the schema in `openapi.yaml`. One edit, but source-breaking, so it
  wants a minor-version bump and a note — <doc:Roadmap>.

## TD-6 — The only real validation is the live suite — **obligation**

Nobody but us checks `openapi.yaml` against the API. Offline stub tests prove the client
decodes what the document *claims*; only a live call proves the claim. Live tests need an
`AUTH_TOKEN`, a Yandex Delivery account, and — for `createClaim` — the willingness to create
a real claim.

- **Cost:** the most valuable tests are the ones least often run, and a Yandex-side change
  is invisible until it breaks a user.
- **Discharge:** none available; this is the standing cost of <doc:SpecOwnership>. Mitigated
  by keeping the live suite in CI on a schedule rather than on every push, and by treating
  a `.undocumented` response in the wild as a spec bug report.

## TD-7 — Dead files kept as scaffolding — **open**

`Errors.swift` (30 lines) and `Client+samples.swift` (11 lines) are 100 % commented-out code
copied from `YooMoneyAPIClient` — payments, receipts, `ValidationError` — retained as
templates. `YandexDeliveryExpressAPIClient.swift` carries a further 81-line commented-out
`LenientISO8601Transcoder` draft, superseded by the transcoder that actually ships. And
`FlexibleISO8601Transcoder.swift` still opens with Xcode's `// File.swift` placeholder
header.

- **Cost:** 122 lines that a reader must classify as irrelevant, and grep hits for types that
  do not exist here.
- **Discharge:** delete. The templates are one `git log` away in the other repository, and
  a commented-out block is not a design document — this catalog is.

## TD-8 — `Types+CustomStringConvertable.swift` is misspelled — **open**

`Convertable` → `Convertible`. Trivial, but the file-naming convention is
`Type+ProtocolName.swift`, so the name is currently wrong in the one way the convention
exists to prevent.

- **Discharge:** rename with `git mv` as part of the TD-2 fix.

## TD-9 — Three abandoned spec drafts live in the sample-app repo — **open**

`YandexDostavka/` holds `yandex-delivery-express-openapi_corrected.yaml` (457 lines),
`_corrected_v2.yaml` (1,197 lines) and `express-delivery_corrected.yaml` (279 lines), plus
two Markdown transcriptions. The package's `openapi.yaml` (2,006 lines) supersedes all of
them, and `_corrected_v2.yaml` is missing `/claims/cancel-info` entirely.

- **Cost:** four candidate documents, no marker saying which is authoritative; a future
  session can regenerate from the wrong one.
- **Discharge:** delete the drafts, or move them to an `Archive/` folder with a README
  naming `openapi.yaml` as authoritative. Keep the Postman collection — it is a live-traffic
  record, which is evidence, not a draft.

## See Also

- <doc:SpecOwnership>
- <doc:Roadmap>

# Tech Debt

Known compromises and defects carried by this package. Each entry names what it costs and
the change that discharges it. Reference an item from code with `// TODO(TD-n): …`.

Status legend: **open** (accepted for now) · **blocking** (must be fixed before the package
builds or ships) · **obligation** (permanent cost of a deliberate design choice) ·
**discharged** (kept for its number and its history; nothing to do).

Numbers are never reused. TD-1 through TD-4, TD-7 and TD-8 were the "this repository does
not compile" set and are all discharged; TD-10 onward were found while discharging them.

## TD-1 — The package did not build — **discharged**

`Package.swift` declared target `YandexDeliveryExpressAPI` while the sources sat in
`Sources/YandexDeliveryExpressAPIClient/` and `Sources/GeneratedSources/`, the test target
had the same mismatch, and the generator plugin was never attached to anything.

- **Discharged by:** `b863b2e` (move the tree to match the manifest) and `f840a78` (attach
  the build plugin, raise the floor). `swift build` succeeds from a clean checkout.

## TD-2 — `CustomStringConvertible` recursed infinitely — **discharged**

Four operation outputs implemented `description` as `"\(self)"`. String interpolation calls
`String(describing:)`, which prefers `CustomStringConvertible`, so `description` called
itself — a stack overflow on the **success** path of `createClaim`, `getClaimInfo`,
`acceptClaim` and `cancelClaim`.

- **Discharged by:** `df826b6`. `Encodable.prettyJSON` is the single rendering; each output
  switches over its own cases. `GetClaimCancelInfo.Output` gained the conformance it never
  had, so all six operations work through the documented logging path. Pinned by
  `DescriptionTests`, under a time limit because a recursive `description` crashes the test
  runner rather than failing a test.

## TD-3 — Localized strings resolved against the wrong bundle — **discharged**

`String(localized:comment:)` with no `bundle:` searches `Bundle.main` — the consuming app —
so every lookup failed silently and returned the key. There was also no String Catalog to
resolve against, and the `.undocumented` case wrote `Payload: payload` as literal text.

- **Discharged by:** `736029c`. All call sites pass `bundle: #bundle`;
  `Resources/Localizable.xcstrings` carries twelve keys with `ru` translations and is
  declared as a processed resource. See **TD-10** for the part of this that could not be
  fixed here.

## TD-4 — The test target contained another package's tests — **discharged**

`Tests/…/YandexDeliveryExpressAPIClientTests.swift` was a verbatim copy of
`YooMoneyAPIClient`'s XCTest suite — `final class YooClientTests`,
`@testable import YooMoneyAPI`, payments.

- **Discharged by:** `b863b2e` (delete) and `abc3fdd` / `2243b54` (the suites in
  <doc:TechDebt>'s companion test plan). Thirty-five offline tests run with no network and
  no credentials.

## TD-5 — `value1` / `value2` is public API — **open**

`RoutePointWithAddress` is an annotation-only `allOf`, so the generator emits a
`value1`/`value2` pair that callers must construct by hand. A generator implementation
detail is part of this package's surface. Full analysis in <doc:SpecOwnership>.

- **Cost:** the single worst-reading construct in the API, reproduced at every call site
  that builds a route point.
- **Discharge:** flatten the schema in `openapi.yaml`. One edit, but source-breaking, so it
  wants a minor-version bump and a note — <doc:Roadmap>.
  `RoutePointEncodingTests.routePointWithAddressEncodesFlat` is already written as the
  safety net: the wire format must not change when the Swift shape does.

## TD-6 — The only real validation is the live suite — **obligation**

Nobody but us checks `openapi.yaml` against the API. Offline stub tests prove the client
decodes what the document *claims*; only a live call proves the claim. Live tests need an
`AUTH_TOKEN` and a Yandex Delivery account.

- **Cost:** the most valuable tests are the ones least often run, and a Yandex-side change
  is invisible until it breaks a user. Sharpened by the fixtures: with no captured response
  in the repository, every offline fixture is derived from the document, so the offline
  suite cannot disagree with the document on its own.
- **Discharge:** none available; this is the standing cost of <doc:SpecOwnership>. Mitigated
  by running the live suite on a schedule rather than on every push, and by treating an
  `.undocumented` response in the wild as a spec bug report.

## TD-7 — Dead files kept as scaffolding — **discharged**

`Errors.swift`, `Client+samples.swift`, an 81-line commented-out `LenientISO8601Transcoder`
draft, a commented-out idempotency-key block, and an Xcode `// File.swift` placeholder
header.

- **Discharged by:** `b863b2e` and `0e54826`.

## TD-8 — `Types+CustomStringConvertable.swift` was misspelled — **discharged**

`Convertable` → `Convertible`, renamed with `git mv` in `b863b2e`.

## TD-9 — Three abandoned spec drafts live in the sample-app repo — **open**

`YandexDostavka/` holds `yandex-delivery-express-openapi_corrected.yaml` (457 lines),
`_corrected_v2.yaml` (1,197 lines) and `express-delivery_corrected.yaml` (279 lines), plus
two Markdown transcriptions. The package's `openapi.yaml` (2,006 lines) supersedes all of
them, and `_corrected_v2.yaml` is missing `/claims/cancel-info` entirely.

- **Cost:** four candidate documents, no marker saying which is authoritative; a future
  session can regenerate from the wrong one.
- **Discharge:** delete the drafts, or move them to an `Archive/` folder with a README
  naming `openapi.yaml` as authoritative. Keep the Postman collection — it is a live-traffic
  record, which is evidence, not a draft. Belongs to the sample-app repository, not this one.

## TD-10 — SwiftPM does not compile the String Catalog — **open**

Measured against Swift 6.3.3 / Xcode 26.6: SwiftPM's **native** build system copies
`Resources/Localizable.xcstrings` into the resource bundle verbatim. It never runs
`xcstringstool`, so under a plain `swift build` / `swift test` the module reports
`Bundle.module.localizations == ["en"]` and every lookup returns the source string. Swift
Build — Xcode, or `swift build --build-system swiftbuild` — produces the expected
`ru.lproj/Localizable.strings`.

- **Cost:** the `ru` column exists in the catalog but not in a natively-built artifact, and
  the TD-3 regression test has to be gated on
  `Bundle.module.localizations.contains("ru")` rather than simply asserting. A consumer who
  builds with SwiftPM directly gets English.
- **Discharge:** not ours. Either SwiftPM's native build system grows an `.xcstrings` rule,
  or the package ships pre-compiled `en.lproj` / `ru.lproj` `.strings` files alongside the
  catalog — which trades one source of truth for two and is worse. Revisit when the default
  build system changes; `--build-system swiftbuild` in CI is the cheap workaround today.

## TD-11 — `acceptClaim` has no live test — **open**

Five of six operations are exercised by `LiveClientTests` or `LiveMutatingTests`.
`acceptClaim` is not, because accepting starts the real courier search and is precisely what
turns a later cancellation from free into billable — a suite that accepts cannot also
promise to clean up after itself.

- **Cost:** the one operation whose response shape (`ClaimAcceptResponse`) is never checked
  against the real API. Under <doc:SpecOwnership> that means its schema is the least
  trustworthy in the document.
- **Discharge:** a Yandex Delivery sandbox or test account where acceptance costs nothing.
  This is an account question, not a code one.

## TD-12 — Sample data shipped inside the library target — **discharged**

The author confirms the addresses, names, phone numbers and e-mail addresses are **fictional**.
`Types+examples.swift` moved to `Tests/YandexDeliveryExpressAPITests/SampleData.swift` and
lost its `public`, so 452 lines of sample data are no longer public API compiled into every
consuming app. The provenance is recorded in the file's header rather than left for the next
reader to re-litigate — as it was here, twice, by two reviewers.

**This hands work to `YandexDostavka`.** The sample app was the only consumer, in sixteen
places: fourteen `#Preview` blocks, and — less obviously — `CalculateOffersViewModel` and
`CreateClaimViewModel`, whose `setupDefaults()` prefills the demo's forms from
`.exampleSimpleRoute` / `.exampleSmallOrder` at *runtime*. The app must declare its own,
which is where they belonged anyway: prefilled form state is presentation, and this is the
same argument as TD-13. Nothing is lost — `git show 0eb35cb:Sources/YandexDeliveryExpressAPI/Types+examples.swift`
is the file to copy from.

The package is unreleased, so this breaks no published API.

<details><summary>The original entry, kept because the reasoning is the point</summary>

### Sample data ships inside the library target — was **open**

`Types+examples.swift` (452 lines) is compiled into the shipping target, so its route
points, contacts and cargo items are `public` API in every app that links this package.

Names, phone numbers and e-mail addresses in it look synthetic — the names and one phone
number are copied from `openapi.yaml`'s own `Contact` examples, and the domains are
`example.com`, reserved for documentation by RFC 2606. Two entries are less obviously
fiction: `exampleMoscowOffice` carries `doorCode: "301К"` with an apartment and floor, and
`exampleMoscowApartment` carries coordinates to six decimal places — sub-metre precision,
where the other three examples use four and point at city-centre landmarks unrelated to
their own street addresses.

`YooMoneyAPIClient` hit exactly this and resolved it by removing the fixtures from the
shipping target: its `Migration` article records that they "embedded a real person's email
address and INN in the binary of every app that linked this package", and the equivalents
now live in its test target.

- **Cost:** personal data, if any of it is real, is in a published binary and in git history.
  Even if all of it is fiction, 452 lines of sample data is public API surface that has to be
  kept compiling.
- **Discharge:** the author confirms whether the two Moscow addresses are real premises, then
  either move the file to `Tests/…/Fixtures.swift` (the YooMoney precedent) or keep it in the
  target behind `#if DEBUG` with the door code and precise coordinates replaced. **Do before
  the repository is made public.**

</details>

## TD-13 — `Types+.swift` puts view-model logic in a transport library — **open**

`public extension [Components.Schemas.RoutePointBase]` adds `newRoutePoint` and
`addRoutePoint` to an `Array` of a public element type, and derives a new `pointId` as
`max + 1`.

- **Cost:** choosing identifiers is a presentation concern — the sample app is the only
  caller — and the derivation is simply wrong if the API ever assigns point ids server-side.
  The extension is also unnamespaced: it applies to every array of that element type in
  every consumer.
- **Discharge:** move it into the sample app, or replace it with a static factory on
  `RoutePointBase` that takes the id rather than inventing one. Bundle with the TD-5
  flattening so callers recompile once.

## TD-14 — One log path ignores `bodyLoggingConfiguration` — **open**

`OSLogLoggingMiddleware` logs successes with `logger.debug` and honours the body policy, but
logs *failures* with `logger.warning("Request failed. Error: \(error.localizedDescription)")`,
which never consults `BodyLoggingPolicy` at all.

Scope, measured rather than assumed. `ClientError` has two renderings, and this path takes
the smaller one: `localizedDescription` resolves to `LocalizedError.errorDescription`, which
is operation id, cause and underlying error — **not** the `CustomStringConvertible`
`description`, which interpolates `operationInput` and would carry every name, phone number
and door code in the request. So a failure does not dump the body. Two things still make it
worth an entry:

- It is the only path a caller cannot switch off. Someone who wrote `.never` has reason to
  expect that nothing derived from their request is logged.
- `Logger.warning` is `.error` level, which the unified logging system **persists to disk**;
  `Logger.debug` is not persisted by default. The one unswitchable path is also the durable
  one. Its argument is interpolated `privacy: .auto`, so it renders as `<private>` in normal
  collection — but a sysdiagnose profile or an attached debugger reveals it.

- **Cost:** small and bounded, but it is an exception to a guarantee this package's default
  otherwise makes cleanly.
- **Discharge:** upstream, in `OSLogLoggingMiddleware` — either route the failure log through
  the policy too, or annotate it `privacy: .private` explicitly. Folded into the "extract
  `AuthMiddleware`" work in <doc:Roadmap> → Later, which already opens that package.

Found by asking DeepWiki to check a conclusion already drawn from the source, which is the
value of asking: the source read was right about headers, privacy levels and `.never`, and
wrong that every path goes through `logger.debug`. Index pinned at `52150c4b`, 0 commits
behind that repository's HEAD.

## TD-15 — Two request-shape changes were unverified against the real API — **discharged**

Both settled by a live run on 2026-08-12, which is the only thing that could have settled
them.

1. **The two body-less POSTs send no `Content-Type`.** `getClaimInfo` with a well-formed but
   non-existent claim id returned **404 `not_found`** — a documented case, decoded normally.
   Not 415, not a gateway refusal: the request shape is accepted. Removing the middleware's
   global `application/json` was correct.
2. **Request timestamps now carry fractional seconds.** `calculateOffers` was sent
   `due = 2026-08-12T19:11:15.790Z` and returned **200** with an offer whose
   `delivery_interval.from` was `19:11:15` — the server both accepted the fractional stamp
   and honoured it.

- **Scope, and it is not a formality:** item 2 is discharged *for `calculateOffers`*. Per
  TD-16 this API does not use one timestamp format, so `createClaim` still needs its own
  evidence before anything is claimed about it. Item 1 is complete, because only two
  operations send no body and both share the shape.

## TD-16 — Timestamp formats vary *within a single response* — **obligation**

Reported by the author from live debugging, then confirmed on the wire on 2026-08-12 — and
the capture is worse than the report. **This API does not use one timestamp format**, and the
variance is not merely per-operation: one `offers/calculate` response carried **21 timestamps
with six-digit fractional seconds and 4 with none**, including a single `TimeInterval` object
whose `from` had a fraction and whose `to` did not:

```json
"pickup_interval": {
  "from": "2026-08-12T17:12:40.051944+00:00",
  "to":   "2026-08-12T18:15:00+00:00"
}
```

Same object, same field type, same response. `Fixtures.offersCalculateResponseJSON` is that
capture, kept precisely because no fixture written from the document would ever have looked
like this.

The whole client contradicts that. `FlexibleISO8601Transcoder` is installed once, on the
`Configuration`, so swift-openapi-generator applies it to *every* `date-time` field in every
operation — one reader and one writer for a surface that is not uniform. It works so far
because the reader is permissive; the writer is the exposure, since it emits one shape
everywhere.

- **Cost:** every conclusion about timestamps is operation-scoped, and nothing in the type
  system says so. A green live test for `offers/calculate` does not license a claim about
  `claims/create`, and TD-15 must therefore be discharged **per operation** rather than
  once. The fixtures cannot help — they are derived from a document that describes the
  format uniformly, which is itself now suspect (<doc:SpecOwnership>).
- **Discharge:** not a fix, an obligation. As live evidence arrives, record the observed
  format for each operation and direction against the schema in `openapi.yaml`, per the
  provenance-comment item in <doc:Roadmap>. If two operations genuinely disagree, a single
  `DateTranscoder` is the wrong shape and the answer is per-field coding rather than a
  cleverer transcoder — one more reason the fallback ladder deserved its reputation
  (<doc:Design>).

## What one live run has actually established

Recorded here because it is the first real-response evidence this package has ever had, and
because the register should say what is *known* as well as what is owed.

Run 2026-08-12 against the production endpoint with a token that turned out to be expired.
The call returned **401 with `{"code": "unauthorized", "message": "Access denied"}`**, which
confirms more than it looks:

- The server URL in `openapi.yaml` resolves and answers.
- `AuthMiddleware` produces a header the server parses — it refuses the *credential*, not
  the request shape.
- **`ErrorResponse` decodes from a real response.** The shared `{code, message}` body is no
  longer only a claim of the document; one schema is now evidence-backed.
- A documented non-2xx arrives as a case rather than a throw, against the real API, which is
  the two-channel rule holding outside the stub transport.

It establishes nothing about TD-15: a 401 is decided before a body or its `Content-Type` is
examined.

## TD-17 — `/offers/calculate` returns an undocumented 409 — **discharged**

The first spec defect found the way <doc:SpecOwnership> says they will be: a live call came
back `.undocumented`, which is a bug report about our own document.

```
409  {"code":"estimating.too_many_loaders",
      "message":"В выбранном кузове не получится заказать столько грузчиков"}
```

A domain refusal — `cargo_loaders` are not orderable on the `express` tariff — carrying the
shared `{code, message}` body, on an operation whose document declared only 400, 401, 429 and
500. Callers saw `.undocumented(409, _)` and had nothing to switch on.

- **Discharged by:** adding `'409': $ref: '#/components/responses/Conflict'` to the operation
  in `openapi.yaml`, with the observed body quoted at the edit. The fix is in the document,
  not in Swift, which is the whole point of owning it. The generator then made the change
  impossible to ignore: `CalculateOffers.Output` gained a `.conflict` case and every
  exhaustive `switch` over it stopped compiling until it was handled.
- **Left open deliberately:** the other five operations have not been probed for undocumented
  statuses. This one was found by accident, which is not a strategy —
  `LiveClientTests.decodeReviewSweep` exists to find the rest, and the provenance-comment
  item in <doc:Roadmap> is what would make each one answerable.

## TD-18 — Sample requests were never validated by the API — **discharged**

`OfferRequirements.exampleExpressDelivery` set `cargoLoaders: 1` alongside
`taxiClasses: [.express]`. Every live call built from it — which is every live call, since it
backs `Operations.CalculateOffers.Input.sample` — was refused with the 409 above before
reaching anything the test meant to check. The fixture had been wrong since it was written
and no offline test could tell, because a stub transport accepts whatever you send it.

- **Discharged by:** dropping `cargoLoaders` from the express sample, with the reason and the
  API's own error message recorded on the declaration.
- **The general lesson, which is TD-6 from the other side:** offline fixtures prove the
  client can *encode* a request, never that the request is one the API will accept. Sample
  data used by live tests wants the same provenance discipline as sample data used for
  decoding.

## See Also

- <doc:SpecOwnership>
- <doc:Roadmap>

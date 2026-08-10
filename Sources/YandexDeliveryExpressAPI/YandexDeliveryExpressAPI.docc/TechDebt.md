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
  <doc:TechDebt>'s companion test plan). Twenty-nine offline tests run with no network and
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

## TD-12 — Sample data ships inside the library target — **open**

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

## TD-15 — Two request-shape changes are unverified against the real API — **open**

Both are believed correct, both are offline-pinned, and neither can be confirmed without a
live call. Grouped because they have one discharge: run the live suite before tagging.

1. **The two body-less POSTs now send no `Content-Type`.** `getClaimInfo` and
   `getClaimCancelInfo` have no request body, so the generator sets no content type for
   them; deleting the middleware's global `application/json` therefore changed exactly these
   two operations, which previously carried a header describing a body they do not have.
   That is the correct HTTP shape, and Yandex may still want the header.
   `RoutePointEncodingTests.bodylessOperationsSendNoContentType` pins what we now send.
2. **Request timestamps now carry fractional seconds.** Fixing the lossy `encode` changed
   `OfferRequirements.due` from `2026-08-07T10:32:14Z` to `2026-08-07T10:32:14.822Z`. Valid
   ISO-8601 and within the document, but it is the request side, where a strict server is
   the only thing that can tell us we are wrong.
   `RoutePointEncodingTests.encodesRequestTimestamp` pins the exact string.

- **Cost:** two ways an otherwise-correct change could break live calls, invisible to every
  offline test by construction — the offline suite can only assert what we decided to send.
- **Discharge:** one run of `LiveClientTests` plus one of `LiveMutatingTests` against a real
  account, before tagging `0.1.0`. Both were found by review rather than by testing, which
  is the point of the review step.

## See Also

- <doc:SpecOwnership>
- <doc:Roadmap>

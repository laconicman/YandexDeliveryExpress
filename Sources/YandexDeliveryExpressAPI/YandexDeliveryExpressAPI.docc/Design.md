# Design

Why this client is generated, how it is put together, and the decision behind each
load-bearing choice — with the alternative that was rejected.

## The specification is ours, so defects get fixed at the source

This is the decision everything else follows from, and it is the opposite of
`YooMoneyAPIClient`'s situation. YooKassa publishes an official document that is wrong in
ways a generator cannot tolerate, so that package treats it as an untrusted input and
derives its generator input through a `SpecSync` tool. Yandex publishes nothing, so
`openapi.yaml` here is **hand-authored and owned**.

That means there is no transform pipeline, no upstream snapshot, and no drift class — and,
importantly, **no reason to work around a spec defect in Swift**. When the generated
surface reads badly, the correct fix is an edit to the document, not an extension that
papers over it. See <doc:SpecOwnership> for what that obligates in return.

**Rejected:** porting `SpecSync`. A tool that normalises an upstream document is pure cost
when there is no upstream document to normalise (YAGNI).

## Generated code is not committed

The **build plugin** generates `Client.swift` and `Types.swift` into the build directory on
every build. Nothing generated is committed.

The argument that made `YooMoneyAPIClient` commit its generated code — that the generator's
input is *derived*, so a build plugin would hide half the pipeline — does not exist here.
With a hand-written document, the reviewable diff is the diff of `openapi.yaml` itself,
which is smaller, more meaningful, and already under review. Committing 5,970 lines of
generated Swift alongside it buys a second, redundant view of the same change and
introduces a way for the two to disagree.

- **Cost:** a clean build regenerates ~6k lines; `Types.swift` is not browsable in the
  repository. At this spec size (52 schemas, 6 operations) that is seconds, not minutes.
- **Rejected:** the command plugin with committed output — which is what this package did
  before, and which never worked, because `Package.swift` declared a target that could not
  see `Sources/GeneratedSources/` (see <doc:TechDebt> item 1).

## One module

`YandexDeliveryExpressAPI` is a single target. The hand-written layer extends generated
types directly (`Types+Identifiable.swift`, `Types+CustomStringConvertible.swift`), and
across a module boundary every one of those extensions would have to be `public` and the
generated namespace re-exported.

**Rejected:** the two-module split (`…OpenAPI` generated + façade), which `GitLabKit` uses
to keep a 65k-line generated module out of the incremental loop. This module is a
twentieth of that. Revisit only with a measurement — see <doc:Roadmap>.

## The platform floor is iOS 17 / macOS 14

Raised from iOS 14 / macOS 11. The old floor was aspirational: nothing in the package was
reachable below iOS 15 without an `@available` guard, so the low floor bought reach that
callers could not actually use, at the price of an availability annotation on nearly every
declaration and a runtime `#available` branch around the logging middleware.

iOS 17 rather than iOS 16 (which is where `YooMoneyAPIClient` sits) because the consumers
of this package are SwiftUI apps, and iOS 17 is where `Observation` becomes unconditional —
the sample app can then be written the way a modern app would be, with no backport layer in
the demonstration path. `String(localized:)`, `Date.ISO8601FormatStyle` and
`FloatingPointFormatStyle` all predate it comfortably.

**Cost:** devices on iOS 15–16 cannot use the package. This is an unofficial client for a
Russian B2B logistics API consumed by business apps; that population is negligible.

**Rejected:** keeping the floor low and annotating generously — the guidance for a library
meant for broad reuse. It does not apply to a client for one vendor's B2B endpoint, and the
existing code shows the tax: the availability annotations were already inconsistent with
each other before this change.

## Localized text uses the module bundle

Anything user-facing in this package resolves through `#bundle` (or `Bundle.module`).
`String(localized:)` with no bundle argument searches `Bundle.main` — the *app's* bundle —
so in a package the lookup silently fails and the key is returned verbatim. That was
happening throughout `Types+CustomStringConvertible.swift`. `Package.swift` declares the
String Catalog as a processed resource so `Bundle.module` exists at all.

One measured caveat, because it decides what a test can assert: **SwiftPM's native build
system does not compile `.xcstrings`.** It copies the catalog into the resource bundle
verbatim, so under a plain `swift build` / `swift test` the module bundle reports
`localizations == ["en"]` and every lookup returns the source string. Swift Build — Xcode,
or `swift build --build-system swiftbuild` — runs `xcstringstool` and produces the expected
`ru.lproj/Localizable.strings`. The `bundle:` argument is what fixes the bug either way;
the translations simply do not exist in an artifact the native build system produced.
Measured against Swift 6.3.3 / Xcode 26.6.

## Authentication is a middleware, and it does one thing

`AuthMiddleware` sets `Authorization`. It is `package`-scoped rather than `public`: a
caller who needs different headers writes their own middleware and passes it, which is the
composable answer and keeps this type from growing options.

The generator can *model* a security scheme but cannot *perform* one, so authentication is
a middleware in any design. What is worth stating is what the middleware must **not** do:
it must not set `Content-Type` (the generator sets that per-operation from the document —
overriding it globally is how a future multipart or query-only operation breaks), and it
must not synthesise idempotency keys (see below).

**Rejected:** folding logging into the same middleware. Auth and logging change for
different reasons — SRP — and
[`OSLogLoggingMiddleware`](https://github.com/laconicman/OSLogLoggingMiddleware) already
exists.

## The caller owns any idempotency key

`AuthMiddleware` carries a commented-out block that derived an idempotency key from
`operationID` plus `body.hashValue` and appended it as a query parameter. It is deleted
rather than revived, for the reason `YooMoneyAPIClient` learned the hard way: `HTTPBody` is
a class, so `hashValue` is identity-based, and a retry of the *same* request produces a
*different* key — the precise failure the mechanism exists to prevent. Middleware also
cannot know what "the same logical request" means; only the caller can.

Yandex's Express API does not currently document an idempotency header. If it gains one, it
becomes a parameter in `openapi.yaml` and therefore an argument the caller must supply.

## Dates go through one transcoder

Yandex returns ISO-8601 timestamps with inconsistent fractional-second precision, so
`FlexibleISO8601Transcoder` tries a fractional-seconds `Date.ISO8601FormatStyle` and then a
plain one. That is the whole type.

It used to be a four-rung ladder — a "modern" format style followed by two `DateFormatter`
fallbacks — and measuring it is what collapsed it. The modern rung matched *nothing*: it was
built as `Date.ISO8601FormatStyle().time(includingFractionalSeconds: true)`, and `.time(_:)`
**selects** the time fields rather than adding to them, so the style formatted and parsed
`08:32:14.822` with no date part and every real timestamp fell through to the
`DateFormatter`s. Spelled with `init(includingFractionalSeconds:timeZone:)` instead, the two
format styles parse every shape the old ladder did — `Z` and `±hh:mm` and `±hhmm`, one, three
or six fraction digits — and still reject `"not a date"`.

The rule that produced this stands: a parse path is justified only by a wire shape the API
actually emits, each pinned by an argument of `DateTranscoderTests.parsesWireTimestamp` with
a citation. A rung no test names is dead code, and deleting it is the point of measuring.

One caveat this design takes on: `Date.ISO8601FormatStyle` is Foundation's, which on Apple
platforms means the *OS's*, so "it parses six fraction digits with a colon-separated offset"
is a claim about a parser we do not ship. It is verified on the build toolchain and on
iOS 18.2 — two major versions below it — but **not** on the iOS 17 floor, for which no
simulator runtime is installed. Running the suite against the oldest available runtime is
therefore part of the CI item in <doc:Roadmap>, not an optional extra.

`encode(_:)` writes fractional seconds. Writing seconds only — which it used to do
unconditionally — made `decode(encode(date))` lossy for any `Date` with sub-second
precision.

## Amounts are validated against the document, not against a formatter

Prices cross the wire as decimal strings, and `openapi.yaml` pins every one of them to
`^-?[0-9]{1,14}(\.[0-9]{0,4})?$`. `Double.init?(wireDecimalString:)` checks that shape and
then parses with the locale-independent `Double.init(_: String)`; the `en_US`
`FloatingPointFormatStyle` is used only for **writing**.

Reader and writer accept the same set — both four fraction digits — because anything else
makes a round trip lossy *inside* the contract: with the writer capped at two, `"12.3456"`
read back exactly and then wrote out as `"12.35"`. Trailing zeros are still dropped, so
ordinary two-decimal money is unchanged.

Checking the pattern rather than trusting a parser is the decision. We own the document, so
it *is* the definition of a well-formed amount — and the parser is worse than useless here:
`Double("807,6", format: style)` does not fail, it reads the digits before the separator and
returns `807`. A device in a comma-decimal locale would have lost the fraction with nothing
downstream looking wrong.

**Rejected:** the previous shape, `String.double` returning `0.0` on failure. It put a member
called `.double` on every `String` in every consuming app and answered "malformed price"
with "free". The initializer is failable so that a caller can tell a bad amount from a
genuine zero.

## Bodies are not logged unless the caller asks

`Client.init(…, bodyLoggingConfiguration:)` defaults to `.never` and passes the argument
through. A `createClaim` body carries recipient names, phone numbers, street addresses,
apartment and floor numbers, and door codes; there is no maximum byte count at which logging
that by default is right. The parameter used to be accepted and then ignored in favour of
`.upTo(maxBytes: 4000)` — the identical defect `YooMoneyAPIClient` fixed in its 2.0.

Reading `OSLogLoggingMiddleware` at `52150c4` for this, and checking that reading against
DeepWiki: header fields are never logged at all, so `Authorization` cannot reach the unified
log under any policy; method, path and status are `privacy: .public`; bodies are
`privacy: .auto`, so they render `<private>` in ordinary log collection even when a policy
does let them through. One path — the failure log — ignores the policy entirely; that is
<doc:TechDebt> TD-14, and it is bounded because it logs `localizedDescription` rather than
the `ClientError` description that would carry the request.

## Live tests are split by whether they change anything

`LiveClientTests` is read-only and gated on `AUTH_TOKEN`. `LiveMutatingTests` creates a real
claim and needs `YDE_ALLOW_MUTATING_LIVE_TESTS=1` as well, because a token cannot tell a
test account from a production one and the difference is somebody's money. Both suites
answer to `--skip "Live API"`.

**Rejected:** one suite with the lifecycle marked `.disabled`. It was safe and useless in
the same move — a test nothing can run is not a test, and it cannot be scheduled either.

## `Identifiable` conformances are hand-written, and that is proportionate

The generator cannot emit protocol conformances, so `Types+Identifiable.swift` lists them.
`GitLabKit` generates the equivalent from a tool that walks the spec's schema closure,
which is the better answer *at its scale*. Ten conformances over a spec that changes a few
times a year does not pay for a tool (YAGNI, Occam's razor). Revisit if the entity set
grows — <doc:Roadmap>.

## See Also

- <doc:SpecOwnership>
- <doc:TechDebt>
- <doc:Roadmap>

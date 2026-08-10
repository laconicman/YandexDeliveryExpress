# Code-session handoff — YandexDeliveryExpressAPI

Rewritten 2026-08-10, after the restoration described below. Delete this file once the "Now"
section of `Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md` is
done — the DocC catalog is authoritative from that point on, and a stale handoff is worse
than none.

**Read first:** `Design.md`, `SpecOwnership.md`, `TechDebt.md`, `Roadmap.md` in
`Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/`. This file is the *task
list*; those are the *reasons*. Where they disagree, believe the catalog.

## Decisions already made — do not relitigate

| Decision | Value | Where the reasoning lives |
|---|---|---|
| Platform floor | iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1 | `Design.md` |
| Code generation | Build plugin; nothing generated is committed | `Design.md` |
| Modules | One (`YandexDeliveryExpressAPI`) | `Design.md` |
| Spec | Hand-authored and owned; fix defects in the YAML, not in Swift | `SpecOwnership.md` |
| Sample app | Separate repo (`YandexDostavka`), consumes this package | `YandexDostavka/HANDOFF.md` |

## State: the package builds, and is tested

The four independent reasons it did not compile — TD-1 through TD-4 — are discharged, along
with TD-7 and TD-8. `swift build` succeeds from a clean checkout with no `path:` argument;
`swift test --skip "Live API"` runs twenty-nine tests with no network and no credentials;
`swift package generate-documentation --target YandexDeliveryExpressAPI` renders all five
articles with no unresolved links.

Five defects were found while fixing those four, none of them in the original diagnosis:

1. `FlexibleISO8601Transcoder.modernFormatter` matched nothing —
   `Date.ISO8601FormatStyle().time(includingFractionalSeconds: true)` **selects** the time
   fields rather than adding to them, so it parsed `08:32:14.822` with no date part.
2. `encode(_:)` truncated sub-second precision on every write.
3. `bodyLoggingConfiguration` was accepted and ignored, logging names, phones, addresses and
   door codes regardless of what the caller asked for.
4. `String.double` returned `0.0` for anything unreadable — and, worse, the underlying
   format style is *lenient*: `Double("807,6", format:)` returns `807` rather than failing.
5. `GetClaimCancelInfo.Output` had no `CustomStringConvertible` conformance at all, so one of
   the six operations could not go through the documented logging path.

Each is one commit, in order, on top of a skeleton commit and a pure-rename commit.

## What is left

In `Roadmap.md` order. Nothing here blocks anything else except the first item.

### 1. Decide `Types+examples.swift` — TD-12, needs the author

452 lines of sample route points, contacts and addresses compiled into the **shipping**
target, so they are public API in every consuming app and are already in git history.

Most of it is demonstrably fiction: the names and one phone number are copied from
`openapi.yaml`'s own `Contact` examples, and every e-mail domain is `example.com` (RFC 2606,
reserved for documentation). Two entries are not obviously fiction:

- `Address.exampleMoscowOffice` — `Москва, ул Москворечье, 6`, with `doorCode: "301К"`,
  `sflat: "301"`, `sfloor: "3"`, `porch: "А"`.
- `Address.exampleMoscowApartment` — `Москва, Каширское шоссе, 52`,
  `coordinates: [37.668176, 55.646068]`, `sflat: "15"`, `sfloor: "1"`.

The coordinate is to six decimal places — sub-metre — where the other three examples use
four and point at city-centre landmarks unrelated to their own street addresses. The two
addresses are about a kilometre apart in the same Moscow district. A door code is the single
most sensitive field the API has.

`YooMoneyAPIClient` made this call already, the hard way: its `Migration` article records
that the equivalent fixtures "embedded a real person's email address and INN in the binary of
every app that linked this package", and they now live in its test target.

**Do this before the repository is public.** Either move the file to
`Tests/YandexDeliveryExpressAPITests/Fixtures.swift`, or keep it behind `#if DEBUG` with the
door code and the precise coordinate replaced.

### 2. CI

`swift build` and `swift test --skip "Live API"` on push. Use
`--build-system swiftbuild` so the String Catalog is compiled and the localization
regression test runs instead of self-skipping (TD-10). With the build plugin there is no
drift check to write.

### 3. Publish

Tag `0.1.0`, push, submit to the Swift Package Index. Then repoint `YandexDostavka` from
`.package(path:)` to the URL — see its own `HANDOFF.md`, and note that the app must commit
its `Package.resolved` while this package must not.

### 4. Everything else

`Roadmap.md` → Next and Later, and the open register: TD-5 (`value1`/`value2`), TD-9 (spec
drafts in the sample-app repo), TD-10 (SwiftPM and `.xcstrings`), TD-11 (`acceptClaim` has
no live test — needs a sandbox account), TD-13 (`newRoutePoint` is view-model logic).

## Things a future session should not re-derive

- **`swift build` will not compile `Resources/Localizable.xcstrings`.** Only Swift Build
  does. This is TD-10, and it is why one test is gated rather than unconditional.
- **A `Regex` cannot be a global constant** in Swift 6 language mode — it is not `Sendable`.
  `DecimalStrings.swift` spells out the document's pattern by hand for that reason.
- **A trait on `@Suite` cannot reference a static member of the type it is attached to**
  ("circular reference resolving attached macro"). `LiveMutatingTests` puts its gate in a
  file-scope constant.
- **`xcodebuild` needs `-skipPackagePluginValidation`.** Otherwise the generator plugin's
  trust check fails the build with "Validate plug-in 'OpenAPIGenerator'" and no useful
  message — it is Xcode waiting for a click that never comes. `swift build` is unaffected.
- **The offline fixtures are derived from `openapi.yaml`, not captured.** The repository's
  only live-traffic record, the sample app's Postman collection, stores requests and no
  responses. This is the sharp edge of TD-6, and giving every schema a provenance comment
  (`Roadmap.md` → Next) is what would blunt it.

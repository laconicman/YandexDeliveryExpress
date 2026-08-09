# Code-session handoff — YandexDeliveryExpressAPI

Written 2026-08-07. Delete this file once the "Now" section of
`Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md` is done — the
DocC catalog is authoritative from that point on, and a stale handoff is worse than none.

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

## The headline: this repository does not compile

Not "has warnings" — does not build, and has never built in this state. Four independent
reasons, all in `TechDebt.md` as TD-1 … TD-4:

1. `Package.swift` declares target `YandexDeliveryExpressAPI`, so SwiftPM looks in
   `Sources/YandexDeliveryExpressAPI/`. The code is in
   `Sources/YandexDeliveryExpressAPIClient/` + `Sources/GeneratedSources/`. Same mismatch on
   the test target. The generator plugin is not attached to anything.
2. Four `CustomStringConvertible.description` implementations return `"\(self)"`, which
   calls `description`. Stack overflow on the success path of four of six operations.
3. `String(localized:)` in a package with no `bundle:` reads `Bundle.main`; there is no
   String Catalog anywhere.
4. The test file is `YooMoneyAPIClient`'s, verbatim — `class YooClientTests`,
   `@testable import YooMoneyAPI`, payments.

Treat the current `Sources/GeneratedSources/` as a *stale artifact from a build that
happened elsewhere*, not as ground truth.

---

## Step 1 — Repository skeleton

Use the `repo-init` skill's checklist; the DocC catalog it asks for is already written.

```
git init && git checkout -b main
```

Then add, at the repo root:

- **`.gitignore`** — copy `YooMoneyAPIClient/.gitignore` verbatim. Note it ignores
  `Package.resolved`; that is right for a library (consumers resolve their own) and wrong
  for the sample app, which must commit its `Package.resolved`.
- **`LICENSE`** — Apache 2.0, matching `YooMoneyAPIClient`.
- **`.spi.yml`**:
  ```yaml
  version: 1
  builder:
    configs:
      - documentation_targets: [YandexDeliveryExpressAPI]
  ```
- **`CLAUDE.md`** — already written, in this directory.

Commit the skeleton before touching sources, so the restructure below is a reviewable diff
rather than an initial import. Follow `atomic-commits` for the sequence.

## Step 2 — Restructure the source tree

Target layout (SwiftPM defaults throughout — no `path:` argument anywhere):

```
Sources/
└── YandexDeliveryExpressAPI/
    ├── YandexDeliveryExpressAPI.docc/     ← already written
    │   ├── YandexDeliveryExpressAPI.md
    │   ├── Design.md
    │   ├── SpecOwnership.md
    │   ├── TechDebt.md
    │   └── Roadmap.md
    ├── Resources/
    │   └── Localizable.xcstrings          ← new, see Step 5
    ├── openapi.yaml
    ├── openapi-generator-config.yaml
    ├── YandexDeliveryExpressAPIClient.swift → Client+init.swift
    ├── AuthMiddleware.swift
    ├── Credentials.swift
    ├── DecimalStrings.swift               ← extracted, see Step 6
    ├── FlexibleISO8601Transcoder.swift
    ├── Types+.swift
    ├── Types+Identifiable.swift
    └── Types+CustomStringConvertible.swift
Tests/
└── YandexDeliveryExpressAPITests/
```

Moves and deletions:

| Action | Path | Why |
|---|---|---|
| `git mv` | `Sources/YandexDeliveryExpressAPIClient/` → `Sources/YandexDeliveryExpressAPI/` | TD-1 |
| `git mv` | `…/Types+CustomStringConvertable.swift` → `Types+CustomStringConvertible.swift` | TD-8 |
| `git mv` | `…/YandexDeliveryExpressAPIClient.swift` → `Client+init.swift` | `swift-file-organization`: the file declares an extension on `Client`, so name it for that |
| `git mv` | `Sources/Resources/` → `Sources/YandexDeliveryExpressAPI/Resources/` | must live inside the target |
| **delete** | `Sources/GeneratedSources/` | build plugin generates it |
| **delete** | `Sources/YandexDeliveryExpressAPIClient/Errors.swift` | 100 % commented-out YooMoney code (TD-7) |
| **delete** | `Sources/YandexDeliveryExpressAPIClient/Client+samples.swift` | ditto (TD-7) |
| **delete** | `Tests/YandexDeliveryExpressAPIClientTests/` | TD-4 |
| **delete** | every `.DS_Store` | six of them, before the first commit |

Also strip the ~90-line commented-out `LenientISO8601Transcoder` draft from
`Client+init.swift`, and the commented-out idempotency block from `AuthMiddleware.swift`
(`Design.md` explains why that idea is not coming back). Fix the `// File.swift` header on
the transcoder.

## Step 3 — `Package.swift`

Replace wholesale:

```swift
// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "YandexDeliveryExpressAPI",
    defaultLocalization: "en",
    // iOS 17 / macOS 14: `Observation` is unconditional for SwiftUI consumers, and every
    // `@available` guard the package used to carry disappears. See the DocC `Design` article.
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .visionOS(.v1)],
    products: [.library(name: "YandexDeliveryExpressAPI", targets: ["YandexDeliveryExpressAPI"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
        .package(url: "https://github.com/laconicman/OSLogLoggingMiddleware", from: "1.0.0"),
        // Renders the DocC catalog, including the direction articles.
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "YandexDeliveryExpressAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "OSLogLoggingMiddleware", package: "OSLogLoggingMiddleware")
            ],
            resources: [.process("Resources/Localizable.xcstrings")],
            // The generator is a *plugin*, never a `dependencies:` entry. It finds
            // `openapi.yaml` and `openapi-generator-config.yaml` by scanning the target's
            // files, so those two must stay in the target's sources — not excluded, and not
            // declared as resources (which would copy the YAML into every consuming app).
            // SwiftPM may report them as unhandled; that is expected.
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .testTarget(
            name: "YandexDeliveryExpressAPITests",
            dependencies: ["YandexDeliveryExpressAPI"]
        )
    ]
)
```

Verify with `swift package dump-package` before building, then `swift build`. Xcode will ask
to trust the plugin on first build.

## Step 4 — Delete the availability scaffolding

Every one of these is now unconditional at the iOS 17 floor. Removing them is the point of
raising it, and leaving any behind is worse than not raising it at all.

- `Client+init.swift` — the `if #available(macOS 11.0, *)` branch around
  `OSLogLoggingMiddleware`; both `@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)`
  annotations.
- `FlexibleISO8601Transcoder.swift` — the `@available(iOS 15, macOS 12, …)` on
  `modernFormatter` and the `if #available` inside `decode(_:)`.
- `Types+CustomStringConvertible.swift` — all eight `@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)`.

Twelve `@available` annotations in live code (3 + 1 + 8), plus three more inside the
commented-out blocks being deleted, and two `if #available` runtime branches.
`grep -rn '@available' Sources` must come back empty.

The transcoder's `DateFormatter` fallbacks are a **separate question**. They are no longer OS
compatibility; keep only the ones a test proves Yandex actually emits (`Design.md`), delete
the rest. Also note the bug you will find while looking: `encode(_:)` uses `withoutFractional`
unconditionally, so a `Date` with sub-second precision round-trips lossily.

Also: the middleware currently sets `request.headerFields[.contentType] = "application/json"`
for every operation. Delete that line — the generator sets `Content-Type` per operation from
the document, and a global override is a bug waiting for the first non-JSON body.

## Step 5 — Localization

1. Create `Sources/YandexDeliveryExpressAPI/Resources/Localizable.xcstrings` (an empty
   String Catalog — Xcode: New File → String Catalog).
2. Add `bundle: #bundle` to every `String(localized:)` call in
   `Types+CustomStringConvertible.swift`. Without it the lookup hits `Bundle.main` and
   silently returns the key (TD-3).
3. Fix `Payload: payload` → `Payload: \(payload)` in the `.undocumented` case.
4. Build once so Xcode syncs the keys into the catalog, then fill in the `ru` column — the
   API is Russian-facing and the sample app defaults to `acceptLanguage: .ru`.

## Step 6 — Fix `CustomStringConvertible` (TD-2)

The four `"\(self)"` bodies are infinite recursion. Replace them with one generic
implementation rather than four hand-written switches — every one of these outputs is
`Encodable`, and the file's own `TODO` already names the approach:

```swift
// One home for "render a generated type for a human". DRY: the four operation outputs
// differ only in which cases exist, and JSON is a better answer than a bespoke switch.
extension Encodable {
    var prettyJSON: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8)
        else { return String(localized: "Could not encode response", bundle: #bundle) }
        return string
    }
}
```

Then each operation's `description` switches on its cases and renders the decoded body via
`prettyJSON`, exactly as `CalculateOffers.Output` already does for its error cases. **Do not**
implement `description` by interpolating `self` anywhere in this package, and add the
regression test named in `Test-Plan.md` — a `description` that recurses is invisible to the
compiler and obvious to a test.

While you are in the file: `CalculateOffers.Output.description` repeats
`(try? error.body.json.message) ?? String(localized: "Unknown error")` four times. One
helper, four call sites.

## Step 7 — `Credentials` must not `fatalError`

```swift
// Current — kills the process, so a test cannot skip itself, and a caller cannot recover.
public static let fromEnvironment: Self = {
    guard let authToken = ProcessInfo.processInfo.environment["AUTH_TOKEN"] else {
        fatalError("AUTH_TOKEN environment variable is not set. …")
    }
    return .init(authToken: authToken)
}()
```

Replace with the shape `YooMoneyAPIClient` settled on, which is what makes
`.enabled(if:)`-gated live tests possible:

```swift
public extension Credentials {
    /// Reads `AUTH_TOKEN` from the environment. `nil` when unset, so callers and tests can
    /// decide what that means. In Xcode, set it under Edit Scheme → Run → Environment.
    static var environment: Self? {
        ProcessInfo.processInfo.environment["AUTH_TOKEN"].map(Self.init(authToken:))
    }
}
```

Keep `fromEnvironment` as a `@available(*, deprecated, renamed: "environment")` alias only if
something outside this repo already calls it; the sample app is the only consumer and is
being rewritten anyway, so prefer a clean removal.

## Step 8 — Tests

`Test-Plan.md`, in this directory. Swift Testing, not XCTest. Write the offline suites before
the live one; they are what make every later step reviewable.

## Step 9 — README

The current README documents the *command* plugin workflow
(`swift package generate-code-from-openapi`) and has a `// TODO: provide example` where the
usage sample should be. Rewrite against the build plugin, add a real example, and link the
DocC articles the way `YooMoneyAPIClient`'s README does — a table pointing at Design /
SpecOwnership / TechDebt / Roadmap, with a line declaring the catalog authoritative.

## Step 10 — Tag, push, then point the sample app at the URL

The sample app is meant to consume this package **by URL**, which it cannot do until this
repository exists remotely. Sequence:

1. Finish steps 1–9; `swift build && swift test --skip "Live API"` green.
2. Tag `0.1.0` and push.
3. In `YandexDostavka`, replace the local reference with the URL dependency.

Until step 2, the sample app uses `.package(path:)`. Say so in its README so nobody mistakes
the local reference for the intended shape.

---

## Enhancement suggestions — raise these, decide deliberately

Not part of "make it build". Each is a real improvement with a real cost; none should be
done reflexively.

### `public extension String { var double: Double }` is API pollution

`Client+init.swift` adds `.double` to **every `String` in every app that imports this
package**, and it returns `0.0` when parsing fails — a silently wrong number where a
`nil` belongs. Same for `Double.string`. Recommendation: move both into `DecimalStrings.swift`
(mirroring `YooMoneyAPIClient`), make the parse `Double?` or `throws`, and consider scoping
them `package` unless a consumer genuinely needs them. This is a breaking change; bundle it
with the `RoutePointWithAddress` flattening so callers recompile once.

Related: `Client.floatingPointFormatStyle` is a number formatter stored as a static on a
network client. Low cohesion — it belongs beside the conversions it serves.

### `Types+.swift` extends `[Components.Schemas.RoutePointBase]`

A public extension on `Array` of a public element type. It is narrower than the `String` case
but the same shape of decision. Consider a namespaced free function or a static factory on
`RoutePointBase` instead.

`newRoutePoint` derives a new `pointId` as `max + 1`. That is a *view-model* concern (the
sample app is the only caller), and it is wrong if the API ever assigns ids server-side.
Consider moving it into the sample app entirely — it is presentation logic living in a
transport library.

### Convenience call shorthands

`Client+samples.swift` is being deleted, but the idea behind it was sound: the six operations
take verbose nested inputs. Once the API surface settles, a `Client+convenience.swift` with
`calculateOffers(route:items:language:)`-style overloads would pay for itself. Do it *after*
the `value1`/`value2` flattening, not before — otherwise you are writing convenience wrappers
around a shape you are about to change.

### `namingStrategy` and `nameOverrides`

`idiomatic` is already set and correct. Read `SpecOwnership.md` before reaching for
`nameOverrides`: it is safe for property names (the `_type` case) and actively broken for
operation names. The operations here already have good `operationId`s, so there is nothing to
override.

Consider adding to `openapi-generator-config.yaml`:

```yaml
additionalFileComments:
  - "swiftlint:disable all"
```

Generated code should not be linted, and with the build plugin you can no longer edit it to
silence a rule.

### Dependencies

Nothing here wants `swift-algorithms` or `SwifterSwift` — the collection work is a `max()`
and a `map`, which is smaller than either dependency. Worth stating so it does not get
re-asked. The dependency that *would* earn its place is the extracted `AuthMiddleware`
package (`Roadmap.md`, Later), because it removes duplicated code across three repositories
rather than adding a new capability.

### Concurrency

`swift-tools-version: 6.1` means Swift 6 language mode. `Credentials` is already `Sendable`;
the generated `Client` is a `Sendable` struct; `AuthMiddleware` is a `Sendable` struct.
Expect the migration to be quiet — but if a test needs to capture what a middleware produced,
use an `actor` box rather than a `nonisolated(unsafe) var` (the deleted test file used the
latter).

## Acceptance criteria

- [ ] `swift build` succeeds from a clean checkout with no `path:` argument in `Package.swift`.
- [ ] `swift test --skip "Live API"` passes with no network and no `AUTH_TOKEN`.
- [ ] `swift package generate-documentation --target YandexDeliveryExpressAPI` renders all
      five articles with no broken `<doc:>` links.
- [ ] `git ls-files | grep GeneratedSources` returns nothing.
- [ ] `grep -rn 'YooMoney\|payment\|Payment' Sources Tests` returns nothing.
- [ ] `grep -rn 'String(localized:' Sources | grep -v '#bundle'` returns nothing.
- [ ] `grep -rn '@available' Sources` returns nothing.
- [ ] Every `TODO(TD-n)` marker in the sources resolves to a live entry in `TechDebt.md`.

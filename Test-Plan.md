# Test plan — YandexDeliveryExpressAPI

Swift Testing throughout (`import Testing`, `@Test`, `#expect`, `#require`). XCTest stays
only for the sample app's UI automation. Today the test target contains zero tests for this
package — see `TechDebt.md` TD-4.

**Ordering principle.** Write every offline suite before the live one. Offline tests prove
the client decodes what `openapi.yaml` *claims*; live tests prove the claim. The first group
runs on every push with no credentials; the second is the only thing that validates a
hand-authored spec, and it is expensive (`TechDebt.md` TD-6).

Target: `Tests/YandexDeliveryExpressAPITests/`.

---

## 1. `Tags.swift` — selectable behaviour

Tags, not naming conventions, per `swift-testing-expert`. `swift test` filters on name
regexes, so give the live *suite* a display name you can `--skip`; the tags are what make
them selectable in Xcode test plans.

```swift
import Testing

extension Tag {
    /// Talks to the real Yandex API. Needs `AUTH_TOKEN`, may create a real claim.
    /// Command-line escape hatch: `swift test --skip "Live API"`.
    @Tag static var live: Self

    /// Pins a claim `openapi.yaml` makes about the API. A failure means either the document
    /// is wrong or Yandex changed — see the `SpecOwnership` article.
    @Tag static var specContract: Self

    /// Pins a bug that shipped. Deleting one of these needs a reason.
    @Tag static var regression: Self
}
```

## 2. `Fixtures.swift` — data and a transport stub

The offline suites all need the same two things: realistic JSON, and a `ClientTransport`
that returns it without a network.

- `StubTransport: ClientTransport` — returns a canned `(HTTPResponse, HTTPBody)`; init takes
  `status:` and `json:`.
- `Client.stubbed(status:json:)` — a `Client` wired to `StubTransport` with the real
  `FlexibleISO8601Transcoder`, so decoding tests exercise the production configuration.
- `RecordingTransport: ClientTransport` — captures the outgoing `HTTPRequest` and body into
  an `actor` box, then returns a canned response. Needed by the middleware suite; **an actor,
  not `nonisolated(unsafe) var`**, because the target is in Swift 6 language mode.
- Fixture JSON, one constant per response, each carrying a comment naming where it came
  from: a Yandex doc page, or the `Базовые запросы.postman_collection.json` in the sample-app
  repository, or a captured live response. Provenance matters more here than in a package
  with an official spec — a fixture invented from the document tests nothing.

Minimum fixture set: `offersCalculateResponseJSON`, `claimCreateResponseJSON`,
`claimInfoResponseJSON`, `claimCancelInfoResponseJSON`, `errorResponseJSON` (the shared
`{"code":…, "message":…}` shape).

`Fixtures.swift` also holds the request-side sample data. The package currently ships
`Types+examples.swift` (452 lines) inside the **library** target — sample route points,
contacts and cargo items. Decide deliberately where that belongs: previews in the sample app
need it at runtime, so it probably stays in the library behind `#if DEBUG`; but any entry
containing a real name, phone number or address must move to the tests or be replaced with
obvious fiction. Check it — `YooMoneyAPIClient` had exactly this problem and its fixture
customer was a real person's contact details.

---

## 3. `ClaimDecodingTests.swift` — `.specContract`

Does the generated client decode what we say Yandex returns? These are the tests that make
`openapi.yaml` falsifiable offline.

| Test | Asserts |
|---|---|
| `decodesOffersCalculateResponse` | `offers` is non-empty; `price.totalPriceWithVat`, `taxiClass`, `pickupInterval.from/to` all decode; `deliveryInterval.from` is a real `Date`, not epoch zero |
| `decodesClaimInfoResponse` | `id`, `status`, `version`, route points, `pricing` decode; `createdTs` parses |
| `decodesClaimCancelInfoResponse` | `cancelState` decodes to `.free` / `.paid` / `.unavailable` — the value that governs whether cancelling is billable, so decoding it wrong costs money |
| `cancelStateEnumsAreDistinct` | `CancelInfoCancelState` has three cases, `CancelState` has two. The spec calls this out (`Не путать с CancelState`), and it means `.unavailable` from `cancel-info` **cannot** be echoed into `cancelClaim`. Pin both case sets so a future "tidy-up" cannot merge them |
| `decodesDocumentedErrorBody` | A 400 with the shared error shape lands in `.badRequest` with `message` readable — **not** thrown |
| `reportsUndocumentedStatus` | A 418 lands in `.undocumented(statusCode: 418, _)` with the payload intact |
| `rejectsUnknownEnumValue` | A `taxi_class` Yandex might add tomorrow throws rather than silently decoding — pins whether the enums are open or closed, which is a real spec decision |

`rejectsUnknownEnumValue` is the one to think about before writing: if it fails, the answer
may be to change `openapi.yaml` (mark the enum extensible) rather than to change the test.
That is `SpecOwnership` working as designed.

## 4. `RoutePointEncodingTests.swift` — `.specContract`

The request side, which decoding tests do not touch.

| Test | Asserts |
|---|---|
| `routePointWithAddressEncodesFlat` | The `allOf` split does **not** reach the wire: the encoded object has `id` and `fullname` as siblings, and no `value1` / `value2` keys |
| `encodesSnakeCaseWireKeys` | `pointId` → `point_id`, `visitOrder` → `visit_order`, `pointType` → `type` |
| `omitsNilOptionals` | An `OfferRequirements` with everything `nil` encodes as `{}` or is omitted — the sample app relies on this to "save traffic" |

`routePointWithAddressEncodesFlat` is the test that must keep passing across the
`RoutePointWithAddress` flattening in `Roadmap.md` → Next. Write it now; it is the safety net
for that change.

## 5. `DateTranscoderTests.swift` — `.specContract`, parameterized

`FlexibleISO8601Transcoder` has three parse paths. Parameterize rather than writing three
near-identical tests.

```swift
@Test("Every timestamp shape Yandex emits parses", arguments: [
    "2026-08-07T10:32:14.822000+03:00",   // observed: 6 fraction digits, offset
    "2026-08-07T10:32:14+03:00",          // observed: no fraction
    "2026-08-07T07:32:14Z",               // observed: Zulu
])
func parsesWireTimestamp(_ raw: String) throws { … }
```

Every argument must be a string **actually observed** from the API, cited in a comment. A
fallback formatter with no argument backing it is dead code — delete the formatter, not the
test (`Design.md`).

Then the round-trip, which exposes a live bug:

| Test | Asserts |
|---|---|
| `roundTripsWithoutLosingPrecision` | `decode(encode(date)) == date`. **Expect this to fail today**: `encode(_:)` uses the `withoutFractional` formatter unconditionally, so sub-second precision is discarded. Fix `encode`, don't weaken the test |
| `throwsOnUnparseableInput` | `#expect(throws: DecodingError.self)` for `"not a date"` — the transcoder must fail loudly, not return `.distantPast` |

## 6. `AuthMiddlewareTests.swift` — `.regression`

Uses `RecordingTransport`.

| Test | Asserts |
|---|---|
| `setsBearerAuthorizationHeader` | `Authorization` is exactly `Bearer <token>` |
| `doesNotOverrideContentType` | The middleware leaves `Content-Type` to the generator. Pins the deleted line from `HANDOFF.md` Step 4 |
| `doesNotMutateThePath` | No query parameter is appended. Pins the deleted idempotency-key experiment, whose failure mode was silent (`Design.md`) |
| `passesThroughResponseUnmodified` | Status and body survive the middleware |

## 7. `DescriptionTests.swift` — `.regression`

The suite that would have caught `TechDebt.md` TD-2. A `description` that calls itself is
invisible to the compiler and trivially visible to a test — but a stack overflow *crashes the
test runner* rather than failing a test, so guard it with a time limit.

```swift
@Suite("Descriptions", .tags(.regression), .timeLimit(.minutes(1)))
struct DescriptionTests { … }
```

| Test | Asserts |
|---|---|
| `outputDescriptionsTerminate` | Parameterized over all six operation outputs built from fixtures: `description` returns, and is non-empty. Termination *is* the assertion |
| `descriptionDoesNotEchoItsOwnType` | `description` does not contain `"Operations."` — the tell-tale of the reflection fallback, which is what `"\(self)"` was reaching for |
| `enumDescriptionsAreLocalized` | `Components.Schemas.CancelState.free.description` resolves through the module bundle. **Set `Locale` explicitly**; a test that passes only because the key equals the English string is not testing anything |

That last one is the TD-3 regression test. The cleanest form: assert the `ru` value, since a
`Bundle.main` lookup cannot produce it.

## 8. `LiveClientTests.swift` — `.live`

Credential-gated, serialized, time-limited. Modelled on `YooMoneyAPIClient/Tests/…/LiveClientTests.swift`.

```swift
@Suite(
    "Live API",
    .tags(.live),
    .enabled(if: Credentials.environment != nil, "Set AUTH_TOKEN to run"),
    .timeLimit(.minutes(1)),
    .serialized
)
struct LiveClientTests { … }
```

`.serialized` is justified here, not habitual: the lifecycle test's steps depend on each
other and on server-side state, which is exactly the case the trait exists for. It requires
`Credentials.environment` from `HANDOFF.md` Step 7 — the current `fatalError`-based
`fromEnvironment` makes `.enabled(if:)` impossible.

| Test | Covers |
|---|---|
| `rejectsBadCredentials` | A bogus token returns `.unauthorized`. **Start here** — it needs no valid account and proves the auth path end to end |
| `calculatesOffersForARealRoute` | Two Moscow addresses return at least one offer with a positive price. Read-only, costs nothing |
| `claimLifecycle` | `createClaim` → `getClaimInfo` → `getClaimCancelInfo` → `cancelClaim`, in **one test**. Splitting it across tests would make them order-dependent, which no framework guarantees. `getClaimCancelInfo` returning `.unavailable` is a legitimate outcome — return early rather than failing |
| `decodeReviewSweep` | Calls each read operation and *records* rather than fails on spec/response mismatches, using `withKnownIssue`. This is the auto-catch diagnostic `GitLabKit` runs; for a hand-authored spec it is the highest-value live test there is, because it turns "Yandex changed something" into a report instead of a mystery |

**Guardrails.** `claimLifecycle` creates a real claim against a real account. It must cancel
what it creates even on failure (`defer`), and it must never run in a `main`-branch CI job
without an explicit opt-in. Ship it as a scheduled nightly job (`Roadmap.md` → Next).

---

## Sample app — `YandexDostavka`

The demo's value is that it *runs*, so keep its test surface small and honest.

- **Delete** the two Xcode template files that assert nothing
  (`YandexDeliveryExpressDemoTests.swift`, and the boilerplate half of the UI tests).
- **`ClaimFormatting` tests** (Swift Testing) — once presentation logic moves out of views
  per `YandexDostavka/HANDOFF.md`, the formatters and derivations are plain functions over
  plain values. Test those; do not test SwiftUI views.
- **Validation tests** — `CalculateOffersModel.isValid` today is `routePoints.count >= 2`,
  which accepts two points with empty addresses. Whatever the real rule becomes, it is a pure
  function and belongs under test.
- **Keep XCTest for `XCUIApplication`** — `swift-testing-expert` is explicit that UI
  automation stays on XCTest. One smoke test that launches, navigates to Calculate Offers and
  finds the submit button is worth more than a suite of view assertions.
- **No live-network UI tests.** The app should take an injected client
  (`YandexDostavka/HANDOFF.md`), so a UI test injects a stub and asserts on rendered state.

## Running

```bash
swift test                       # everything; live suite self-skips without AUTH_TOKEN
swift test --skip "Live API"     # CI default — no network, no credentials
AUTH_TOKEN=… swift test          # includes live
```

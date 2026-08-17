# Test plan — YandexDeliveryExpressAPI

Rewritten 2026-08-10: the plan is built. This is now a description of the suite that exists
plus the gaps it does not cover, rather than a list of things to write.

Swift Testing throughout (`import Testing`, `@Test`, `#expect`, `#require`). XCTest stays
only for the sample app's UI automation.

**Ordering principle, unchanged.** Offline tests prove the client decodes what `openapi.yaml`
*claims*; live tests prove the claim. The first group runs on every push with no credentials;
the second is the only thing that validates a hand-authored spec, and it is expensive
(`TechDebt.md` TD-6).

### Supplying the credential

The token lives in `~/.yandex-auth-token` — outside every repository, mode `600` — and is
read into the environment for the length of one command:

```console
% AUTH_TOKEN="$(cat ~/.yandex-auth-token)" swift test --filter "Live API"
```

Never paste it into a shell history, a commit, a test fixture or an issue. `.gitignore`
carries patterns (`*.token`, `*auth-token*`, `.env*`, `secrets.*`, `*.pem`) so that a copy
made "just for a minute" inside the repository cannot be committed, but the real protection
is that the only copy lives elsewhere.

`AuthMiddlewareTests.errorsDoNotLeakTheCredential` guards the subtler leak: a `ClientError`
renders its request through `prettyDescription`, which prints **every header field
verbatim**. It happens not to carry the `Authorization` header, because
swift-openapi-runtime attaches the request the *serializer* produced rather than the one the
middleware chain modified — an implementation detail, not a promise. If that test ever goes
red, stop running the live suites until it passes again.

```console
% swift test --skip "Live API"                       # CI default — 35 tests, no network
% AUTH_TOKEN=… swift test                            # adds the read-only and unauthenticated live suites
% AUTH_TOKEN=… YDE_ALLOW_MUTATING_LIVE_TESTS=1 \
    swift test --filter "Live API (mutating)"        # creates and cancels a real claim
% swift test --build-system swiftbuild               # also runs the localization test (TD-10)
```

---

## What exists

`Tests/YandexDeliveryExpressAPITests/`

| File | Suite | Tag | Covers |
|---|---|---|---|
| `Tags.swift` | — | — | `.live`, `.mutating`, `.specContract`, `.regression` |
| `Fixtures.swift` | — | — | `StubTransport`, `RecordingTransport` + `RequestRecorder` actor, `Client.stubbed` / `.recording`, six response fixtures |
| `SampleData.swift` | — | — | Request-side samples — route points, contacts, cargo items (moved out of the shipping target, TD-12) |
| `ClaimDecodingTests.swift` | Claim decoding | `.specContract` | The document made falsifiable offline |
| `RoutePointEncodingTests.swift` | Route point encoding | `.specContract` | The bytes that actually leave the process |
| `DateTranscoderTests.swift` | Date transcoding | `.specContract` | Every wire timestamp shape, and the round trip |
| `DecimalStringTests.swift` | Decimal strings | `.specContract` | Amounts in both directions, and what is *not* an amount |
| `AuthMiddlewareTests.swift` | Auth middleware | `.regression` | One thing it does, three it must not, and the credential it must never leak |
| `DescriptionTests.swift` | Descriptions | `.regression` | TD-2, under a time limit |
| `WireCapture.swift` | — | — | `CapturingTransport`, `WireLog`, `WireDrift` — records the wire and diffs it against our types |
| `LiveExplorationTests.swift` | Live API (exploration) | `.live`, `.exploration` | Asks the API what it does; reports, never asserts |
| `LiveUnauthenticatedTests.swift` | Live API (unauthenticated) | `.live` | The auth path, no account needed |
| `LiveClientTests.swift` | Live API | `.live` | Read-only, credential-gated |
| `LiveMutatingTests.swift` | Live API (mutating) | `.live`, `.mutating` | The lifecycle, double-gated |

All three live suites are matched by `--skip "Live API"`, so one flag keeps CI offline.

The unauthenticated suite exists because `rejectsBadCredentials` was gated on exactly the
thing it does not need. It builds its own client with a deliberately bad token, yet inherited
`.enabled(if: Credentials.environment != nil)` — so it never ran on the machine where it is
cheapest, one with no `AUTH_TOKEN`. It now runs with credentials *or* with
`YDE_ALLOW_NETWORK_TESTS=1`, and verifies most of the transport wiring — URL resolution,
header attachment, and a documented 401 arriving as a case rather than a throw — for free.

### Fixture provenance — read this before adding one

`offersCalculateResponseJSON` is **captured from the live API** (2026-08-12); a failure
against it means the client broke. Every other fixture is still derived from `openapi.yaml`'s
own `examples:` and `required:` blocks, which cite Yandex's reference pages. The repository's only live-traffic record — the sample app's
`Базовые запросы.postman_collection.json` — stores requests and no responses.

That is the honest limit of this suite, and it is TD-6 with the safety off: a fixture derived
from the document cannot catch the document being wrong. When a real response is captured,
replace the fixture and say where it came from.

## What each suite pins, and why it is worth keeping

- **`cancelStateEnumsAreDistinct`** — `CancelInfoCancelState` has three cases,
  `CancelState` has two. The spec says «Не путать с CancelState» in as many words, and it
  decides whether cancelling is billable: `.unavailable` from `cancel-info` **cannot** be
  echoed into `cancelClaim`. Pinning both case sets stops a future tidy-up merging them.
- **`rejectsUnknownEnumValue`** — a `taxi_class` Yandex might add tomorrow throws rather than
  decoding silently, and it throws as `ClientError`, not as a response case. If this ever
  needs to pass instead, the change belongs in `openapi.yaml` (mark the enum extensible), not
  in the test. That is `SpecOwnership` working as designed.
- **`routePointWithAddressEncodesFlat`** — the safety net for the TD-5 flattening. The
  `value1`/`value2` split must not reach the wire, before or after.
- **`roundTripsWithoutLosingPrecision`** — the regression for an `encode` that truncated.
- **`rejectsNonAmounts`** — nine strings that are not amounts, including `"807,6"`, which the
  old reader turned into `807` rather than failing.
- **`doesNotOverrideContentType`** / **`doesNotMutateThePath`** — both pin *deleted* code: a
  global `Content-Type` override and an idempotency key derived from `HTTPBody.hashValue`.
  Each failed silently when it shipped.
- **`outputDescriptionsTerminate`** — parameterized over all six operations. Termination
  *is* the assertion; a recursive `description` crashes the runner rather than failing a
  test, hence the suite's time limit.
- **`enumDescriptionsAreLocalized`** — asserts the `ru` value, because a `Bundle.main`
  lookup (the TD-3 bug) cannot produce it. Gated on
  `Bundle.module.localizations.contains("ru")`: under SwiftPM's native build system the
  String Catalog is copied uncompiled and the translations do not exist to assert (TD-10).

## The exploration harness — how `WorkingWithYandex` gets written

`LiveExplorationTests` is the instrument, not a test in the usual sense. Yandex publishes no
OpenAPI document and its HTML reference is incomplete, so `openapi.yaml` is a hypothesis and
this suite is the experiment. It produced every observation in the `WorkingWithYandex` article.

```console
% AUTH_TOKEN="$(cat ~/.yandex-auth-token)" \
    swift test --filter LiveExplorationTests --attachments-path .build/attachments
```

**`--attachments-path` is required and the directory must exist** — SwiftPM discards
attachments without it, and the evidence is the entire point. Under `xcodebuild`, pass
`-resultBundlePath` and export with `xcrun xcresulttool export attachments`.

It **reports rather than asserts**: raw exchanges become attachments and findings become
`.warning` issues, so a Yandex-side change shows up as a report instead of a red build. The
only failures are client defects. Both mechanisms need Swift 6.2+/6.3+ respectively; this
package's floor is well above that.

Three things it gives a maintainer that reading the reference cannot:

- **`WireDrift.undocumented(in:understoodAs:)`** — decodes a response into the generated type,
  re-encodes it, and diffs the key paths. Keys in the raw payload but not the round trip are
  fields Yandex sends and `openapi.yaml` does not model. No hand-maintained list of "documented
  fields" to drift; the generated types *are* the list.
- **`WireDrift.timestampShapes(in:)`** — the TD-16 census. The run on 2026-08-12 reported
  `fraction(6 digits), offset: 21` and `no fraction, offset: 4` from a single response.
- **The undocumented-status probe** — three deliberately malformed read-only calls. It is how
  TD-17 was found, and it now reports "no undocumented statuses on the probed paths", because
  the document was fixed. That closed loop is the harness working.

`CapturingTransport` sits **below** the middleware chain on purpose: a middleware would see the
`Authorization` header this package is careful never to log.

## Open question: the bounded retry in the mutating cleanup

`LiveMutatingTests.cancel(_:_:with:)` makes one cancellation attempt and, if it fails,
re-reads the claim for a fresh `version` and tries exactly once more.

**For:** the version moves server-side as the claim progresses, so a stale one is the
*expected* race, and the cost of losing it is a billable claim rather than a red test.

**Against:** a retry in a cleanup path can launder a systematic failure — an already-accepted
claim, a token without the scope, a changed endpoint — into something that looks transient,
at the price of two requests and a more confusing log.

It is capped at one, and it re-reads rather than blindly repeating, so a second failure is
evidence about something other than the version. **First data, 2026-08-12 — and it favours the third branch.** A cancellation was refused with
`409 state_mismatch` while the claim was mid-estimation, and *the same claim cancelled
successfully minutes later* from `estimating_failed`. So the rejection was about transient
**state**, not about `version` — which is precisely Devin's "the helper is answering the wrong
question" case.

The retry earns its place, but it is re-reading the wrong field. It should re-read the
**status** and tolerate a transition, not just refresh `version`. Left as-is for now because
one observation is not a pattern, and because changing a cleanup path on one data point is how
you get a cleanup path nobody trusts. Run it a few more times, then fix it deliberately.

## Gaps, deliberate and otherwise

- **`acceptClaim` has no live test** — TD-11. Accepting starts the real courier search and is
  what turns a cancellation from free into billable, so a suite that accepts cannot promise
  to clean up after itself. Needs a sandbox account, not a better guardrail.
- **No offline test asserts a header the generator sets** beyond `Content-Type`. If a future
  operation adds a required header, nothing offline will notice it going missing.
- **No CI runs any of this yet** — `Roadmap.md` → Now.

## Sample app — `YandexDostavka`

Unchanged, and not started; it lives in the other repository.

- **Delete** the two Xcode template files that assert nothing.
- **`ClaimFormatting` tests** (Swift Testing) — once presentation logic moves out of views,
  the formatters and derivations are plain functions over plain values. Test those; do not
  test SwiftUI views.
- **Validation tests** — `CalculateOffersModel.isValid` is `routePoints.count >= 2`, which
  accepts two points with empty addresses. Whatever the real rule becomes, it is a pure
  function and belongs under test.
- **Keep XCTest for `XCUIApplication`.** One smoke test that launches, navigates to Calculate
  Offers and finds the submit button is worth more than a suite of view assertions.
- **No live-network UI tests.** The app should take an injected client, so a UI test injects
  a stub and asserts on rendered state.

# Test plan — YandexDeliveryExpressAPI

Rewritten 2026-08-10: the plan is built. This is now a description of the suite that exists
plus the gaps it does not cover, rather than a list of things to write.

Swift Testing throughout (`import Testing`, `@Test`, `#expect`, `#require`). XCTest stays
only for the sample app's UI automation.

**Ordering principle, unchanged.** Offline tests prove the client decodes what `openapi.yaml`
*claims*; live tests prove the claim. The first group runs on every push with no credentials;
the second is the only thing that validates a hand-authored spec, and it is expensive
(`TechDebt.md` TD-6).

```console
% swift test --skip "Live API"                       # CI default — 29 tests, no network
% AUTH_TOKEN=… swift test                            # adds the read-only live suite
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
| `ClaimDecodingTests.swift` | Claim decoding | `.specContract` | The document made falsifiable offline |
| `RoutePointEncodingTests.swift` | Route point encoding | `.specContract` | The bytes that actually leave the process |
| `DateTranscoderTests.swift` | Date transcoding | `.specContract` | Every wire timestamp shape, and the round trip |
| `DecimalStringTests.swift` | Decimal strings | `.specContract` | Amounts in both directions, and what is *not* an amount |
| `AuthMiddlewareTests.swift` | Auth middleware | `.regression` | One thing it does, three it must not |
| `DescriptionTests.swift` | Descriptions | `.regression` | TD-2, under a time limit |
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

Every fixture in `Fixtures.swift` is derived from `openapi.yaml`'s own `examples:` and
`required:` blocks, which in turn cite Yandex's reference pages. **None is a captured
response.** The repository's only live-traffic record — the sample app's
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

## Open question: the bounded retry in the mutating cleanup

`LiveMutatingTests.cancel(_:_:with:)` makes one cancellation attempt and, if it fails,
re-reads the claim for a fresh `version` and tries exactly once more.

**For:** the version moves server-side as the claim progresses, so a stale one is the
*expected* race, and the cost of losing it is a billable claim rather than a red test.

**Against:** a retry in a cleanup path can launder a systematic failure — an already-accepted
claim, a token without the scope, a changed endpoint — into something that looks transient,
at the price of two requests and a more confusing log.

It is capped at one, and it re-reads rather than blindly repeating, so a second failure is
evidence about something other than the version. **Resolve it with data, on the first real
run:** if the retry never fires, delete it; if it fires and succeeds, the race is real and
belongs in `Design.md`; if it fires and fails, the first rejection was never about the
version and the helper is answering the wrong question. Raised with Devin in the PR-1
discussion — no data either way yet, because nothing has run this live.

## Gaps, deliberate and otherwise

- **`acceptClaim` has no live test** — TD-11. Accepting starts the real courier search and is
  what turns a cancellation from free into billable, so a suite that accepts cannot promise
  to clean up after itself. Needs a sandbox account, not a better guardrail.
- **No offline test asserts a header the generator sets** beyond `Content-Type`. If a future
  operation adds a required header, nothing offline will notice it going missing.
- **`Types+examples.swift` is still in the library target** — TD-12. Whether it moves here is
  the open question in `HANDOFF.md`; if it does, this file is where it lands.
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

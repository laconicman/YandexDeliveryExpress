# Roadmap

Planned work in priority order. Rationale lives in <doc:Design>; the register of what is
wrong today is <doc:TechDebt>.

## Done — the package builds and is tested

Kept as a short record because the whole "Now" section was this, and because the order
mattered: nothing else could start until the package compiled.

The source tree was moved to match the manifest, the generator build plugin was attached,
the floor was raised to iOS 17 / macOS 14, and the copied `YooMoneyAPIClient` test file was
deleted (TD-1, TD-4, TD-7, TD-8). The two crashes on the success path — the recursive
`description` implementations (TD-2) and the wrong-bundle localized strings (TD-3) — are
fixed. Four defects found while doing it were fixed with them: a date transcoder whose
"modern" parse path matched nothing and whose `encode` truncated sub-second precision, an
auth middleware overriding `Content-Type`, a `bodyLoggingConfiguration` argument that was
accepted and ignored, and a decimal-string reader that turned `"807,6"` into `807`.

The offline suite is written: decoding, request encoding, the auth middleware, the date
transcoder, the decimal strings, and the descriptions — thirty-nine tests, no network, no
credentials.

### Flatten `RoutePointWithAddress` — done 2026-08-27

`value1`/`value2` is out of the public API, by editing the document (TD-5,
<doc:SpecOwnership>); `newRoutePoint` left the library with it (TD-13). Source-breaking,
shipped as 0.2.0 with <doc:Migration>. The enums were **not** part of this: TD-20 is
decided, they stay closed, and the vanilla generator output is the surface.

## Now

### Add CI

`swift build` and `swift test --skip "Live API"` on push. With the build plugin there is no
drift check to write — that whole job class disappears (<doc:Design>).

**`--skip "Live API"` is the only thing that guarantees an offline run**, and CI must encode
it rather than rely on credentials being absent. Three suites carry that prefix, and one of
them — `Live API (unauthenticated)` — reaches the network whenever `AUTH_TOKEN` merely
*exists*, deliberately, because it needs no valid account. A runner with a token in its
environment and no `--skip` makes real calls.

Two more flags matter:

- `--build-system swiftbuild`, so the String Catalog is actually compiled and the
  localization test runs rather than self-skipping (TD-10).
- A second job running the suite on the **oldest installed simulator runtime**, because
  `Date.ISO8601FormatStyle` is the OS's parser and the transcoder's whole design rests on
  what it accepts (<doc:Design>). Add `-skipPackagePluginValidation` to any `xcodebuild`
  invocation, or the generator plugin's trust check fails the build non-interactively.

### Publish

`LICENSE`, `.spi.yml` and `swift-docc-plugin` are in place; what remains is tagging `0.1.0`,
pushing, and submitting to the Swift Package Index so these articles are readable without
checking the repository out. Then repoint the sample app from `.package(path:)` to the URL.

**The live suite has now been run** (2026-08-12) and TD-15 is discharged: the body-less POSTs
are accepted without `Content-Type`, and `calculateOffers` accepts and honours a
fractional-second `due`. It also found an undocumented 409 (TD-17) and an invalid sample
request (TD-18), both fixed. All six operations have since been exercised live, including
`acceptClaim` (TD-11), and a decode-breaking closed enum was found and fixed on the way
(TD-19). The TD-20 enum audit is decided — they stay closed — so nothing
source-breaking remains outstanding before a first tag.

## Next

### Give every schema a provenance comment

Now the highest-value item on this list, because one live run showed what it buys: an
undocumented 409, a response format the document describes wrongly, and a sample request the
API refuses — none of which any offline test could have surfaced. Each schema links to the
Yandex reference page it was read from, or is marked as observed on the wire. This is the obligation <doc:SpecOwnership> takes on, and it is what makes a future
"did Yandex change this, or did we get it wrong?" answerable. It is also what would let the
offline fixtures cite a response rather than the document (TD-6).

### Ship the live suite as a scheduled job

Credential-gated, tagged `.live`, running nightly rather than per-push. The `.undocumented`
case is the signal to watch: one in production means the document is wrong (TD-6). The
mutating lifecycle stays behind its second switch and out of any unattended job.

### Re-run the live suites against a production credential

Everything observed so far is from a **test** account, and this API's track record does not
license assuming environments match (<doc:WorkingWithYandex>). The differences, if any, are
recorded in that article rather than by editing the existing claims.

## Later

### Extract `AuthMiddleware`

A one-header client middleware has now been written from scratch in three of this author's
packages. Promoting it to a standalone package alongside
[`OSLogLoggingMiddleware`](https://github.com/laconicman/OSLogLoggingMiddleware) and
[`RefreshTokenAuthMiddleware`](https://github.com/laconicman/RefreshTokenAuthMiddleware)
retires all three copies. Same item as `YooMoneyAPIClient`'s roadmap — do it once, for both.

### Convenience call shorthands

The six operations take verbose nested inputs. A `Client+convenience.swift` with
`calculateOffers(route:items:language:)`-style overloads would pay for itself. The
`value1`/`value2` flattening that blocked this has shipped (0.2.0), so it is now unblocked;
the test-side `init(id:address:)` bridge in `SampleData.swift` is the first recorded
evidence of which shorthand callers actually reach for.

### Generate the `Identifiable` conformances

Only if the entity set outgrows a hand-maintained list. `GitLabKit` computes the active
filter's schema closure and emits `extension …: Identifiable {}` for every entity with an
`id`; that is the right answer at its scale and premature at this one (<doc:Design>).

### Reconsider the module split

If clean-build time becomes painful, split generated types into their own target as
`GitLabKit` does. Not before there is a number that justifies it.

### Cover the rest of the API

Six operations cover the Express lifecycle. Yandex's B2B Cargo API also exposes same-day
delivery, courier tracking, and document retrieval. Each is new schemas in `openapi.yaml`
plus an `operationId` — add one when a caller needs it, not before.

## See Also

- <doc:Design>
- <doc:TechDebt>
- <doc:WorkingWithYandex>

# Roadmap

Planned work in priority order. Rationale lives in <doc:Design>; the register of what is
wrong today is <doc:TechDebt>.

## Now — make it build and make it true

### Restore the package

Rename the source directory to match the target, delete the committed generated sources,
attach the build plugin, raise the floor to iOS 17 / macOS 14, and delete the copied
`YooMoneyAPIClient` test file. Discharges <doc:TechDebt> TD-1, TD-4 and TD-7. Nothing else
on this list can start first.

### Fix the two crashes

The recursive `description` implementations (TD-2) and the wrong-bundle localized strings
(TD-3). Both are on the success path of live code, and both are cheap.

### Write the offline suite

Swift Testing, a `StubTransport` returning canned JSON, one suite per concern: decoding,
encoding, the auth middleware, the date transcoder. No network, no credentials, so it can
run on every push. This is what turns every later change into a reviewable one.

### Add CI

`swift build` and `swift test --skip "Live API"` on push. With the build plugin there is no
drift check to write — that whole job class disappears (<doc:Design>).

## Next

### Flatten `RoutePointWithAddress`

Remove `value1`/`value2` from the public API by editing the document (TD-5,
<doc:SpecOwnership>). Source-breaking, so it lands as one release with a migration note,
together with any other schema shapes worth correcting while callers are already recompiling.

### Give every schema a provenance comment

Each schema links to the Yandex reference page it was read from, or is marked as observed on
the wire. This is the obligation <doc:SpecOwnership> takes on, and it is what makes a future
"did Yandex change this, or did we get it wrong?" answerable.

### Ship the live suite as a scheduled job

Credential-gated, tagged `.live`, running nightly rather than per-push. The `.undocumented`
case is the signal to watch: one in production means the document is wrong (TD-6).

### Publish

`LICENSE`, `.spi.yml`, `swift-docc-plugin`, and a Swift Package Index submission so these
articles are readable without checking the repository out.

## Later

### Extract `AuthMiddleware`

A one-header client middleware has now been written from scratch in three of this author's
packages. Promoting it to a standalone package alongside
[`OSLogLoggingMiddleware`](https://github.com/laconicman/OSLogLoggingMiddleware) and
[`RefreshTokenAuthMiddleware`](https://github.com/laconicman/RefreshTokenAuthMiddleware)
retires all three copies. Same item as `YooMoneyAPIClient`'s roadmap — do it once, for both.

### Generate the `Identifiable` conformances

Only if the entity set outgrows a hand-maintained list. `GitLabKit` computes the active
filter's schema closure and emits `extension …: Identifiable {}` for every entity with an
`id`; that is the right answer at its scale and premature at this one (<doc:Design>).

### Reconsider the module split

If clean-build time becomes painful, split generated types into their own target as
`GitLabKit` does. Not before there is a number that justifies it.

### Cover the rest of the API

Six operations cover the Express lifecycle. Yandex's B2B Cargo API also exposes same-day
delivery (`yandex-delivery-other-day-openapi.md` in the sample-app repository is a partial
transcription), courier tracking, and document retrieval. Each is new schemas in
`openapi.yaml` plus an `operationId` — add one when a caller needs it, not before.

## See Also

- <doc:Design>
- <doc:TechDebt>

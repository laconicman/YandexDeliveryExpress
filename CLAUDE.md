# YandexDeliveryExpressAPI

Unofficial Swift client for Yandex Delivery's Express (B2B Cargo) API, generated with
[swift-openapi-generator](https://github.com/apple/swift-openapi-generator). Sibling of
`YooMoneyAPIClient` and `GitLabKit`; companion sample app lives in `../YandexDeliveryExpressDemo`.

## Direction docs are authoritative

Read these before proposing architecture, and update them when a decision changes. When they
and this file disagree, believe them.

| Article | Answers |
|---|---|
| [Design](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Design.md) | Every load-bearing decision, with the alternative that was rejected |
| [Owning the Specification](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/SpecOwnership.md) | Why `openapi.yaml` is hand-written, and what that obligates |
| [Tech Debt](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/TechDebt.md) | Numbered register (`TD-n`), each with Cost and Discharge |
| [Roadmap](Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/Roadmap.md) | Planned work, priority order |

`HANDOFF.md` is the current task list; `Test-Plan.md` is the suite to build. Both are
temporary and get deleted once consumed.

Render: `swift package generate-documentation --target YandexDeliveryExpressAPI`

## Rules specific to this repository

1. **Fix spec problems in `openapi.yaml`, not in Swift.** We own the document. A hand-written
   extension that works around a generated shape is a workaround with a fixable root cause —
   see `SpecOwnership`. This is the inverse of `YooMoneyAPIClient`, where the document is
   upstream and untouchable.
2. **Never edit generated code, and never commit it.** The build plugin regenerates
   `Client.swift` / `Types.swift` into the build directory. If `Sources/GeneratedSources/`
   reappears, something regressed.
3. **`nameOverrides` is safe for properties, broken for operations.** One override string is
   returned verbatim from both the type and member name positions, so it cannot produce
   idiomatic Swift for an operation's method *and* its `Operations.*` namespace. Use
   `operationId` in the document instead. Verified upstream at `b2064e3f`, 2026-08-06;
   write-up in `../YooMoneyAPIClient/Upstream/nameoverrides-verbatim-casing.md`.
4. **`String(localized:)` needs `bundle: #bundle` here.** Without it the lookup goes to
   `Bundle.main` — the consuming app — and silently returns the key.
5. **Never implement `description` as `"\(self)"`.** String interpolation calls
   `String(describing:)`, which calls `description`. That shipped (TD-2); do not let it
   return.
6. **Platform floor is iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1.** No
   `@available` annotations belong in this package. If you find yourself adding one, either
   the API is above the floor (raise it deliberately, and say why in `Design`) or the code is
   in the wrong place.
7. **Swift Testing, not XCTest.** `#expect` by default, `#require` when later lines depend on
   the value, tags for selection. XCTest only for `XCUIApplication` in the sample app.
8. **Errors are two channels.** Documented non-2xx statuses are enum cases you `switch` on;
   transport and decoding failures are thrown `ClientError`. Do not collapse them.
9. **Reference a debt item from code** as `// TODO(TD-n): …` so the marker and the register
   stay linked.
10. **Replicate wire behaviour that works; change it only on evidence.** Yandex is not
    disciplined about the standards it claims to implement — it says ISO-8601 and does not
    reliably emit it. When existing code sends a shape that worked against the real API,
    keep it and document the question rather than "correcting" it toward the specification
    or toward symmetry. Be liberal in what you accept and conservative in what you send;
    inference is cheap when reading and expensive when writing. Pending questions of this
    kind go in `TechDebt` (TD-15), to be settled by a live call before tagging. See
    `Design` → "Wire behaviour that works is replicated, not reasoned about".

## Author's standing preferences

Clarity over brevity. Prefer a vetted SPM over hand-rolling when the dependency is smaller
than the problem — and say so explicitly when it is *not*, so the question does not get
re-asked. Cite sources in prose and in code comments; when quoting a Q&A answer, weigh the
answer's rank against its actual quality. DRY, separation of concerns, low coupling / high
cohesion are the three that get checked first.

## Related skills

`apple-swift-openapi-generator` · `swift-package-manager` · `swift-testing-expert` ·
`swift-file-organization` · `software-development-principles` · `repo-init` ·
`atomic-commits` · `git-branching`

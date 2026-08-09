# Handoff: what YandexDeliveryExpress can adopt from GitLabKit

Hand this to a future session working on **YandexDeliveryExpress** (YDE,
`/Users/paul/Documents/Code/Gateways/YandexDeliveryExpress`). Both are
`swift-openapi-generator` clients by the same author; GitLabKit is the newer, more hardened
one. This is framed as **Design / Roadmap / Tech-Debt** checks so YDE can be audited for
compliance the same way we review GitLabKit.

> Scope note: GitLab's spec is huge and broken in specific ways; Yandex's is small and
> hand-tended. Some items below (filter tiers, array-retyping) only matter **if** YDE's spec
> shows the same symptoms — each says when it applies.

## Design — architecture to consider

- **DocC catalog for decisions.** GitLabKit ships a `.docc` with `Design`, `Roadmap`,
  `TechDebt`, `UpstreamSpecFix` articles + `swift-docc-plugin`. YDE has only a README. Adopt
  the catalog so architecture decisions and debt are reviewable. *(Applies always.)*
- **Build plugin vs committed code.** YDE commits `Sources/GeneratedSources/{Client,Types}.swift`
  (command-plugin style). GitLabKit uses the **build plugin** — nothing generated is committed,
  so the client can't drift from the spec. Tradeoff: build-plugin = no drift but slower clean
  builds; committed = browsable + fast but must regenerate on spec change. Pick deliberately
  and document it. *(Applies always.)*
- **Two-module split** (`GitLabOpenAPI` generated + `GitLabKit` façade). Pays off on a large
  generated module (incremental builds, SourceKit visibility). YDE's generated code is small,
  so a single module is fine — **don't split just to split**. Note: same-package cross-module
  conformances need **no `@retroactive`** (Swift checks the package boundary).

## Roadmap — tooling/process to add

- **A spec tool** (`swift run …SpecTool`). GitLabKit's `GitLabSpecTool` fetches the upstream
  spec, normalizes it, and writes the vendored copy — all in Swift (replacing a bash script).
  Even if YDE's spec needs no transforms, a fetch+vendor tool gives **reproducible
  re-vendoring**. *(Applies if YDE re-vendors from an upstream source.)*
- **`--ref` pinning.** Pin the fetch to a tag/branch/sha so a regen is reproducible and so an
  upstream fix doesn't silently change your vendored spec. *(Applies with the spec tool.)*
- **Idempotent, guarded transforms.** If YDE's tool ever transforms the spec, guard each
  transform so it's a **no-op on an already-correct spec** (GitLabKit verifies this: a second
  run reports `0/0/0` and is byte-identical). *(Applies if transforming.)*
- **Generate `Identifiable` conformances.** swift-openapi-generator can't emit protocol
  conformances. GitLabKit's tool computes the active filter's schema closure and writes
  `extension Components.Schemas.X: Identifiable {}` for every entity with an `id` — more robust
  and complete than hand-listing. YDE currently hand-rolls `Types+Identifiable.swift`; if its
  entity set grows, generate it the same way. *(The conformance idea is YDE's; GitLabKit took
  it further to generation.)*

## Tech Debt — quality gaps to close in YDE

- **Tests are live-only and credential-bound.** `YandexDeliveryExpressAPIClientTests.swift`
  hits the real API on every `swift test`, needs `Credentials.fromEnvironment`, uses XCTest,
  and even `import YooMoneyAPI` (a stray copy-paste). Port GitLabKit's pattern:
  - an **offline mock-transport test** (a `ClientTransport` that returns canned bodies) for
    deterministic CI with no network/credentials;
  - **opt-in live tests** gated on an env flag (`GITLAB_LIVE_TESTS`), with a public fallback;
  - **Swift Testing** (`@Test`/`#expect`) instead of XCTest;
  - a Swift-6 concurrency-safe capture (an `actor` box) when asserting on what a middleware
    produced.
- **Auto-catch decode diagnostic.** GitLabKit's `liveDecodeReviewEntities` decodes a spread of
  real entities and *reports* spec/response mismatches (array-as-object **and** scalar type
  mismatches) as recorded known issues. Add the equivalent if Yandex responses ever drift from
  the spec. *(Applies if YDE reads list/entity data.)*
- **Filter tiers.** Only if YDE's spec grows large — GitLabKit keeps `review`/`core`/`full`
  config tiers (active one named `openapi-generator-config.yaml`, others excluded). N/A for a
  small spec. *(Applies only at scale.)*

## Already cross-pollinated (GitLabKit adopted FROM YDE)

These came **from** YDE during this work — YDE is the reference for them, no action needed:
- **Flexible ISO-8601 date transcoder** (modern `Date.ISO8601FormatStyle` + fallback).
- **`Types+examples.swift`** (sample data for previews/tests) and the **`Types+X.swift`**
  file-organization convention for generated-type extensions.
- The **`Identifiable` conformance** idea — though GitLabKit then took it further and now
  *generates* it from the tool (see the Roadmap item above), which YDE could adopt back.

## What GitLabKit still owes YDE (reverse direction)

- **`Types+CustomStringConvertible`** with localized `String(localized:)` descriptions — YDE
  does this well; GitLabKit hasn't yet. Worth porting *into GitLabKit* later.
- Richer, domain-specific **sample data** — YDE's `Types+examples` is far more complete.

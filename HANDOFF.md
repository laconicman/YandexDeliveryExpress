# Code-session handoff — YandexDeliveryExpressAPI

Rewritten 2026-09-23 for the journal milestone. Delete this file once `journal`/`search`
ship and the DocC `Roadmap.md` "Now" section reflects them — a stale handoff is worse than
none.

**Read first:** `Design.md`, `SpecOwnership.md`, `TechDebt.md`, `Roadmap.md` in
`Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/`. This file is the *task
list*; the catalog holds the *reasons*. Where they disagree, believe the catalog.

## State

`0.2.1` is tagged on `main`: create/accept/cancel-info/cancel ops, `Client.init(…,
middlewares:)` composing the post-auth chain (TD-23 registers that consumer middleware
sees the bearer token), `bodyLoggingConfiguration:` kept as a forwarder. The app consumes
by URL. TD-22 (live evidence for cancellation semantics) stays open until a real cancel
run — the app's wire log (YD-12) is the intended capture.

## Milestone: `journal` (and `search`) → tag `0.3.0`

The app's Phase 3 needs a claims list: a cancellable claim is only cancellable if the user
can find it, and today's minimal deliveries list loses orders. Demand recorded on the
package Roadmap since 2026-09-02 beside `tariffs`. The journal carries **no coordinates** —
status/price events plus `current_point_id`, verified 2026-08-30 — which is enough for
stop-granularity progress on the app's surfaces.

1. Spec: add `journal` (and `search` if the API exposes it — verify against the provider
   docs before writing the YAML) to `openapi.yaml`. `operationId` naming per
   `SpecOwnership`; rule 11 applies — replicate wire shapes the provider actually emits,
   change only on live evidence.
2. Tests per package conventions (`swift test`); the app's store already keys recorded
   orders by `claimID`, so the join key is settled.
3. Merge, tag `0.3.0`. The app side (separate repo, separate PRs): journal-driven claims
   list → the `3e` history card → cancellation reachable; map point annotations as a
   parallel or following slice.

## Working agreements for the session

- **DeepWiki prospectively** (golden rule): paste the planned spec/API shape and ask for
  objections *before* committing — it can't see unmerged code, so describe the diff
  against what it has indexed. Relay the index commit the answer is pinned at.
- **Wait for Devin Review to finish a round** before pushing fixes; every push triggers a
  fresh pass that often critiques the fix just made (author, 2026-09-22).
- **`contrib` is the obligations ledger**: `contrib in … --json` carries full bodies
  (`text.ask`/`text.reply`) — no `gh api --jq` needed; refresh `in` before `ack` since
  acks fail on stale snapshots; edits can reopen items or rewrite a finding wholesale.
- **Co-think pace** (author, 2026-09-23): ask where a decision is genuinely ambiguous or
  consequential; don't churn. Musk's algorithm applies — question, delete, simplify —
  before adding mechanism.

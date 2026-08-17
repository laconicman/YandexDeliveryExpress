# Working with the Yandex API

What the API actually does, as opposed to what any document says it does — including ours.
Everything here was observed on the wire and is dated. Read it before trusting a schema.

## Why this article exists

<doc:SpecOwnership> says the document is ours and defects get fixed at the source. That is
still true, and it is not the whole story. `openapi.yaml` was written by reading Yandex's HTML
reference, and one afternoon of live calls found an undocumented status, five undocumented
fields, a misspelled field, a route point the API invents, and two error-code vocabularies in
one API.

None of that is reachable from the reference pages. It is only reachable by calling the thing
and looking at the bytes. So this article is the standing record of *observed* behaviour, kept
separately from the document, because the document describes what we believe and this
describes what happened.

**The governing rule is in <doc:Design>:** replicate wire behaviour that works, and change
what we send only on live evidence. This article is the evidence.

## ⚠️ The credential in use is a **test** token

Every observation below was made with a Yandex **test** account. That matters twice:

- **Nothing here costs money**, which is why the mutating suite can be run at all, and why
  claims can be created and cancelled freely while exploring.
- **Production may behave differently, and this API's track record says it will.** An API that
  ships a misspelled duplicate field and two error-code vocabularies is not one whose
  environments can be assumed identical. Treat every statement here as *observed on the test
  environment* until a production call says otherwise.

Nothing can be done about that now, and it is not a reason to distrust the observations — it
is a reason to date them and re-check them. When a production credential exists, re-run the
live suites against it and record the differences here rather than editing the claims.

## Observed 2026-08-12

### The API invents a route point

Create a claim with two route points — a `source` and a `destination` — and the response
contains **three**. Yandex appends a `return` point of its own:

```
point id=26389626087875 type=source      visit=pending
point id=26389626087876 type=destination visit=pending
point id=26389626087877 type=return      visit=pending
```

Nothing in the reference says this. A caller that round-trips `route_points` — reads a claim
and sends the points back — is sending a shape it did not build.

### Point ids are reassigned, not echoed

The request numbered its points `1` and `2`. The response numbered them `26389626087875` and
`26389626087876`. Server-assigned `int64`s, unrelated to what was sent.

This is why deriving a new `point_id` as `max + 1` client-side is wrong (TD-13): the ids a
caller invents survive exactly as long as the request. Any field that references a point —
`items[].pickup_point`, `items[].dropoff_point` — is renumbered with them in the response.

### `droppof_point` — a misspelled field, shipped, alongside the correct one

Every item in a claim response carries both:

```json
"dropoff_point":  26389626087876,
"droppof_point":  26389626087876
```

A typo that reached production and could not be removed without breaking whoever had already
integrated against it, so now both are sent forever. It is the single clearest artefact of the
culture this article documents, and the reason the standing rule is "replicate what works".

We decode `dropoff_point` and ignore its twin. If Yandex ever fixes the spelling, the correct
key is the one still standing.

### Undocumented response fields

Present on the wire, absent from the reference and from `openapi.yaml`:

| Field | Where |
|---|---|
| `last_status_change_ts` | `ClaimResponse` |
| `skip_emergency_notify` | `ClaimResponse` |
| `age_restricted` | `CargoItem` |
| `droppof_point` | `CargoItem` (the typo above) |
| `corp_client_id` | `ClaimResponse` — the account identifier; do not commit one |

Extra keys decode harmlessly — the generator ignores what the schema does not declare — so
these cost nothing until someone needs one. Adding a field to `openapi.yaml` is how it becomes
reachable.

### Two error-code vocabularies

The shared `{code, message}` body carries a **symbolic** code in some cases and a **numeric
string** in others:

```json
{"code":"not_found",                  "message":"Заявка не найдена"}
{"code":"state_mismatch",             "message":"Недопустимое действие над заявкой"}
{"code":"estimating.too_many_loaders","message":"В выбранном кузове не получится заказать столько грузчиков"}
{"code":"400", "message":"Value of query 'claim_id': incorrect size, must be 32 (limit) <= 3 (value)"}
{"code":"400", "message":"Parse error at pos 763, path 'route_points': incorrect size, must be 2 (limit) <= 1 (value)"}
```

Validation failures answer with `"400"` — the status code as a string — and a message that
leaks the parser's internal position. Domain failures answer with a dotted or snake-cased
symbol. **Do not switch on `code` as if it were an enumeration**; it is two vocabularies
sharing a field, and only the symbolic half is stable enough to branch on.

### `cancel-info` says `free`, `cancel` says `state_mismatch`

Read the cancel state of a fresh claim and it answers `{"cancel_state":"free"}`. Cancel it a
moment later and it can answer:

```json
409 {"code":"state_mismatch","message":"Недопустимое действие над заявкой"}
```

The claim was mid-estimation. **The same claim cancelled successfully minutes later**, from
`estimating_failed`. So the refusal was about a transient *state*, not about the version and
not about the claim being uncancellable.

Two consequences, both practical:

- A cancellation that fails is not necessarily a cancellation that will keep failing. Cleanup
  code should re-read and retry — and the thing to re-read is the **status**, not only the
  `version` (see the open question in `Test-Plan.md`, which this is the first real data for).
- `cancel-info` is advisory. It reports what cancelling *would* cost, not that cancelling will
  be accepted.

### Timestamp formats vary within one response

The headline finding, covered in full by <doc:TechDebt> TD-16. One `offers/calculate` response
carried 21 timestamps with six-digit fractional seconds and 4 with none — including a single
`TimeInterval` whose `from` had a fraction and whose `to` did not. `claims/info` responses
observed so far are uniformly six-digit.

This is why `FlexibleISO8601Transcoder`'s reader must stay permissive, and why the
`DateFormatter` ladder that preceded it was empirical rather than defensive.

### Amounts may have no decimal point

`"total_price":"1449"` and `"total_price_with_vat":"1767.78"` in the same object. The
document's pattern permits it and `Double.init?(wireDecimalString:)` accepts it; a reader that
assumed two decimals would be wrong.

### Idempotency works as documented

Re-posting `claims/create` with the same `request_id` returned the same claim id, with the
status it had reached by then rather than a fresh claim. This is the recovery mechanism
`LiveMutatingTests` relies on, and it is the one place the reference's promise held exactly.

### Tariff combinations are validated server-side only

`cargo_loaders` with `taxi_class: express` is refused — `409
estimating.too_many_loaders` — while the same loaders with `cargo` and a `cargo_type` are
accepted. Nothing in the document expresses that constraint, and nothing offline can: a stub
transport accepts whatever you send it. Sample requests used by live tests therefore need
their own validation, which is TD-18.

## How to add to this article

One live call is worth more than an afternoon of reading the reference, and cheaper than a
production incident. When you learn something:

1. Record it here with the date and the raw bytes, not a paraphrase.
2. If it changes what the client should send or accept, fix `openapi.yaml` and say so in
   <doc:TechDebt>.
3. If it contradicts something above, keep both and date them. This API changes without
   announcement, and a superseded observation is evidence about *when* it changed.

## See Also

- <doc:SpecOwnership>
- <doc:Design>
- <doc:TechDebt>

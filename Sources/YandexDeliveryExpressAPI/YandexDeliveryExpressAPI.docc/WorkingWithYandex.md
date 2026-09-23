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

Present on the wire, absent from the reference. The ones that proved useful have since been
added to `openapi.yaml` — they are listed here anyway, because the reference still does not
mention them and re-checking the reference will not explain them:

| Field | Where | In `openapi.yaml`? |
|---|---|---|
| `last_status_change_ts` | `ClaimResponse` — the epoch sentinel below | yes |
| `skip_emergency_notify` | `ClaimResponse` | yes |
| `age_restricted` | `CargoItem` — documented on `V2CargoItem`, added 2026-09-23 | yes |
| `droppof_point` | `CargoItem` (the typo above) | no, deliberately |
| `corp_client_id` | `ClaimResponse` — the account identifier; do not commit one | yes |
| `taxi_offer` | `ClaimResponse` top level, duplicating `pricing.offer`; carries a **numeric** `price_raw` both places | no |
| `route_points[].uuid` | `claims/create` response only — absent from later `info`/`search` reads | no |
| `available_cancel_state` | `claims/create` response only (`"free"`); the cancel terms inline, undocumented | no |
| `features` | `claims/create` response only, an empty array so far | no |

Extra keys decode harmlessly — the generator ignores what the schema does not declare — so
the unmodelled ones cost nothing until someone needs one. Adding a field to `openapi.yaml` is
how it becomes reachable.

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

### A closed enum on a warning cost us the whole response

`warnings[].source` came back as `taxi_requirements`, which our document did not list, and the
entire `claims/info` response failed to decode. Advisory metadata, modelled as a closed
vocabulary, made a claim unreadable — and because a polling loop read `status` through that same
call, claims that *had* reached `ready_for_approval` appeared frozen at `new`.

Two lessons, and the second is the one that generalises: model closed enums only where a caller
must branch exhaustively, and **never let a decode failure in one field decide what you believe
about the rest of the API**. Details in <doc:TechDebt> TD-19.

### The lifecycle does work, on a route the account can service

`exampleSmartphoneDelivery` lands in `estimating_failed` and never becomes acceptable. Two
central-Moscow addresses a few hundred metres apart on the `courier` tariff reach
`ready_for_approval` in about six seconds, and `acceptClaim` then returns 200 `accepted`. So
"the API will not estimate" was really "this request, on this account, will not estimate" —
worth remembering before concluding anything about the API from one failing sample.

`auto_accept: true` skips approval entirely and goes straight to `performer_lookup`.

## Observed 2026-09-23

Verification run for `claims/journal` and `claims/search` (both confirmed POST, both live),
on a test account, including one full create → cancel lifecycle. Nothing was ever accepted,
so no courier moved.

### The journal is a change feed with a signed cursor

`POST /claims/journal` takes an optional `limit` query (default 1000, hard bounds 1–1000 —
`limit=0` is a 400) and an **optional** body: `POST` with no body at all returns 200 with an
empty page. The response is always `{cursor, events}` — both required.

The `cursor` is a signed JWT whose payload carries pagination state
(`{"version":1,"last_known_id":…,"holes":[…]}`). Do not parse it: feed it back verbatim in
`{"cursor": "…"}` and the next page starts after `last_known_id`. A garbage cursor is a 400
with `{"code":"invalid_cursor"}` — one of the only two codes the reference documents.

Events observed during a create → cancel lifecycle, in order: `new`, `estimating`,
`ready_for_approval`, `cancelled`. Each carries `change_type: "status_changed"`,
`claim_id`, `operation_id`, `revision`, `updated_ts`; the cancellation's event additionally
carried `resolution: "failed"` — **a user cancel counts as a *failed* resolution**, not
`success`. `new_price`/`new_currency` accompany `change_type: "price_changed"`, which no
test account of ours has yet emitted.

### Search's body is genuinely a `oneOf` — the server says so

`POST /claims/search` with a malformed body returns:

```json
{"code":"400","message":"Value of '/' cannot be parsed as a variant"}
```

The server parses the body as a variant — so `openapi.yaml` models it as a `oneOf` of a
filter form (`limit` required, max 1000; `offset`, `claim_id`, `phone`, `status`,
`created_from`/`created_to`, `due_from`/`due_to`, `state`, `external_order_id` optional) and
a continuation form (`cursor` only). `limit: 2000` trips the same variant error rather than
a range check — the server never gets as far as validating `limit`.

Filters verified live: `state: "finished"` returned cancelled claims, `state: "active"`
returned none after cancellation, `status: "cancelled"` and `claim_id` both filter as
documented. `Accept-Language` is required (400 without it).

The response is `{claims[], cursor?}`: `claims` is required, `cursor` optional in the
reference but **returned on every page observed**, including single-result pages. It is
base64-encoded JSON carrying pagination state (`{"offset":…,"limit":…,"created_to":…}`) —
equally opaque; echo it back verbatim via the cursor variant. The claims themselves decode
cleanly through `ClaimResponse` — every field the wire sent was either modelled or one of
the extras in the table above.

### `last_status_change_ts` starts at the epoch

A claim whose status has never changed reports `1970-01-01T00:00:00+00:00` — the sentinel is
in the wild, not only in the reference's type list. It becomes a real timestamp after the
first transition.

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

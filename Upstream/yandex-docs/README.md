# Upstream Yandex docs cache

Yandex publishes the Express API reference and the business-cabinet integration page without
versioning. A field's meaning, a status word or the «no test environment» statement can change
with no changelog, and `openapi.yaml` is written by hand against these pages
([Owning the Specification](../../Sources/YandexDeliveryExpressAPI/YandexDeliveryExpressAPI.docc/SpecOwnership.md)). This folder holds a Markdown rendering of every page the spec depends
on, so an upstream change shows up as a diff you can read. Without it, the first sign would be
a failed live call.

The pages are rendered by JavaScript and do not answer a plain HTTP fetch, so capturing them
needs a real browser.

## Layout

| File | What it is |
|---|---|
| `pages.txt` | The page list: `<file-stem> <url>` per line. Add a page here first. |
| `<file-stem>.md` | One captured page. |

Each captured file starts with front matter:

```yaml
---
Source: <url from pages.txt>
Captured: <ISO date>
Title: "<page title>"
SHA-256: <hash of the body below the front matter>
---
```

The hash covers the body only, so re-capturing an unchanged page is not reported as a change,
even though its `Captured` date is new. Run `shasum -a 256` on a file to fingerprint the whole
file, front matter included.

### What the rendering keeps, and the few things it rewrites

The file holds the main content only, without navigation, footer or the «Была ли статья
полезна?» widget. Wording, JSON field names, enum values and deprecation notes are verbatim.
Collapsed sections (`<details>`, «Показать ещё») are expanded before saving. A few things are
rewritten so they survive Markdown:

- **Required properties** are drawn by Diplodoc as a CSS asterisk, which Markdown would drop.
  Here they read `_name_ (required)`.
- **Lists inside table cells** become `<br>`-separated `- item` lines. A GFM cell cannot hold
  a block, and without this rewrite the whole table would stay raw HTML.
- **Heading anchors** are kept as `<a id="…"></a>`, so a diff shows when an anchor this
  repository links to disappears or is renamed.
- **Links and images** are made absolute. Images stay images: the order-flow diagram in
  `claim-process.md` (`status-process.png`) is a picture, so its content is not in the text.
  The status table below it is.

## Re-checking

```sh
scripts/upstream-diff.sh              # capture into a temp dir, report; exit 1 if anything changed
scripts/upstream-diff.sh --write      # also update the cache (same exit status), then `git diff`
scripts/upstream-diff.sh claim-process IntegrationV2ClaimsJournal   # just these pages
```

You need Node 20+ and Google Chrome. The first run installs the pinned dependencies from
`scripts/upstream/package-lock.json`. Chrome runs headless. If Yandex answers with a captcha,
run with `UPSTREAM_HEADED=1` and solve it in the window. `UPSTREAM_BROWSER_CHANNEL=chromium`
or `UPSTREAM_BROWSER_PATH=…` picks another browser. Each page is reported as `unchanged`,
`new`, `moved` (same body, different `Source` URL in `pages.txt`) or `changed` (followed by a
unified diff of the body). The comparison hashes the cached body as it is on disk, so a hand
edit to a cached file does not hide an upstream difference.

This is the cheaper sibling of TD-15's "settle by a live call before tagging": before tagging
a release, re-check here, and re-read the questions below whenever a page changes.

### From a browser this repository does not drive

An agent's browser, or DevTools by hand, can produce the same files, because extraction and
conversion are separate steps:

1. On each page, evaluate the function in `scripts/upstream/extract.js`, with `{}` as its
   argument. It returns `{ url, title, html, container }`.
2. Save the results as a JSON array of `{ "stem", "title", "html", "captured" }`, with the stem
   taken from `pages.txt`.
3. Run `node scripts/upstream/import-snapshot.mjs --pages Upstream/yandex-docs/pages.txt
   --out Upstream/yandex-docs <snapshot.json>`.

Both paths convert through `scripts/upstream/markdown.mjs`, so they write byte-identical
files. The first capture (2026-09-29) was taken this way, in Chrome driven by an agent.

## Questions answered from the cache

These are answered from the captured text only, with the sentence quoted. Re-read them
whenever the check reports a change to the page cited.

1. **Where the API token is obtained.** `dostavka-integrations-api.md`: «Узнать свой
   API-токен можно в личном кабинете в разделе «Ваш профиль».»
2. **Whether a test environment exists.** `dostavka-integrations-api.md`: «У нас нет
   тестовой среды — поэтому интеграцию испытывают на реальных заказах. Если у вас есть
   персональный менеджер, вы можете запросить у него доступ в тестовый кабинет и проверить
   работу системы там.» So there is no test environment, only a test *cabinet*, and only
   through a personal manager.
3. **What address format `route_points[].address` requires.** The two sources disagree.
   `dostavka-integrations-api.md`: «Наша система воспринимает адреса только в формате
   координат.» The reference, `IntegrationV2ClaimsCreate.md` → `CargoPointAddress`, marks only
   `fullname` as required («Полный адрес с указанием города, улицы и номера дома.») and leaves
   `coordinates` optional («Координаты точек в виде массива из двух вещественных чисел:
   долгота, широта — именно в таком порядке.»). `openapi.yaml`'s `Address` follows the
   reference (`required: [fullname]`). Inference, not a quote: send both, with coordinates in
   longitude-then-latitude order. That satisfies either reading.

The business page renders its FAQ twice (two layouts of the same accordion). The capture
keeps both copies, as the page does.

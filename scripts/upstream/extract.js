// Browser-side half of the capture (issue #17): runs *inside* a rendered Yandex page and
// returns its main content as cleaned HTML. Markdown conversion happens in Node
// (`markdown.mjs`), so every capture path produces byte-identical output.
//
// This file is one async function expression, deliberately not a module, so it can be
// evaluated anywhere a page can run script:
//   - `capture.mjs` passes it to Playwright's `page.evaluate`;
//   - any other browser (an agent's, or DevTools by hand) evaluates it and hands the result
//     to `import-snapshot.mjs` — see `Upstream/yandex-docs/README.md`.
//
// Argument: `{ selector?: string }`, which overrides the content-container list.
// Returns:  `{ url, title, html, container }`.
async ({ selector } = {}) => {
  // Main-content candidates, most specific first. `.dc-doc-page__body` is Diplodoc, the
  // engine behind yandex.ru/support (verified 2026-09-29: it holds the article without the
  // mini-TOC or the «Была ли статья полезна?» widget); the rest are fallbacks for
  // dostavka.yandex.ru. The whole <body> is never used — navigation churn would drown the diff.
  const selectors = selector
    ? [selector]
    : ['.dc-doc-page__body', 'main article', 'article', 'main', '[role="main"]'];
  const minChars = 200;
  // Controls that reveal content not yet in the DOM («Показать ещё», «Развернуть»).
  const expanderText = /^\s*(показать\s+(ещё|еще|все|больше)|развернуть(\s+все)?|show\s+more|expand\s+all)\s*$/i;
  const settle = () => new Promise((resolve) => setTimeout(resolve, 500));

  for (let round = 0; round < 20; round += 1) {
    const expanders = [...document.querySelectorAll('button, a, [role="button"]')]
      .filter((element) => expanderText.test(element.textContent) && element.offsetParent !== null);
    if (expanders.length === 0) break;
    expanders.forEach((element) => element.click());
    await settle();
  }

  const root = selectors
    .map((candidate) => document.querySelector(candidate))
    .find((element) => element && element.innerText.trim().length >= minChars);
  if (!root) throw new Error(`no main-content container among: ${selectors.join(', ')}`);

  const content = root.cloneNode(true);
  // UI chrome, not content. `.yfm-anchor` is the empty «#» link inside each heading; the
  // heading keeps its id.
  content.querySelectorAll('script, style, noscript, svg, nav, footer, button, .yfm-anchor')
    .forEach((element) => element.remove());
  // Collapsed sections (Diplodoc's `.yfm-cut` are <details>) and hidden tab panels are already
  // in the DOM, only hidden; the converter reads the DOM, so un-hiding is enough.
  content.querySelectorAll('details').forEach((element) => element.setAttribute('open', ''));
  content.querySelectorAll('[hidden]').forEach((element) => element.removeAttribute('hidden'));
  // Diplodoc tabs: label each panel with its tab title, then drop the tab strip.
  content.querySelectorAll('.yfm-tabs').forEach((tabs) => {
    const labels = [...tabs.querySelectorAll('.yfm-tab')].map((tab) => tab.textContent.trim());
    tabs.querySelectorAll('.yfm-tab-panel').forEach((panel, index) => {
      const label = document.createElement('p');
      const strong = document.createElement('strong');
      strong.textContent = labels[index] ?? `Tab ${index + 1}`;
      label.append(strong);
      panel.before(label);
    });
    tabs.querySelectorAll('.yfm-tab-list').forEach((list) => list.remove());
  });
  // Absolute URLs, so links in the cache resolve outside the site.
  content.querySelectorAll('a[href]').forEach((a) => a.setAttribute('href', a.href));
  content.querySelectorAll('img[src]').forEach((img) => img.setAttribute('src', img.src));

  return {
    url: location.href,
    title: document.title.trim(),
    html: content.innerHTML,
    container: selectors.find((candidate) => document.querySelector(candidate) === root),
  };
}

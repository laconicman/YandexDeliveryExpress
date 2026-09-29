// Node-side half of the capture (issue #17): the page list, HTML → Markdown, and the cache
// file format. Shared by `capture.mjs` (Playwright) and `import-snapshot.mjs` (any other
// browser), so both paths write byte-identical files.
//
// Turndown (https://github.com/mixmark-io/turndown) is the de-facto HTML → Markdown
// converter. Joplin's maintained fork of its GFM plugin
// (https://github.com/laurent22/joplin/tree/dev/packages/turndown-plugin-gfm) is used because
// it converts tables without a <thead> — every table on the Yandex reference pages — which the
// original plugin leaves as raw HTML. Domino is the DOM Turndown already parses with; it is
// imported directly so tables can be flattened before conversion (`flattenTableCells`).

import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import domino from '@mixmark-io/domino';
import TurndownService from 'turndown';
import { gfm } from '@joplin/turndown-plugin-gfm';

/// Parses `pages.txt`: one `<stem> <url>` per line, `#` comments. Returns every page, or
/// only the ones named in `onlyStems` when it is non-empty.
export async function readPages(path, onlyStems = []) {
  const pages = (await readFile(path, 'utf8'))
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('#'))
    .map((line) => {
      const [stem, url] = line.split(/\s+/);
      return { stem, url };
    });
  const unknown = onlyStems.filter((stem) => !pages.some((page) => page.stem === stem));
  if (unknown.length) throw new Error(`not in ${path}: ${unknown.join(', ')}`);
  return pages.filter(({ stem }) => onlyStems.length === 0 || onlyStems.includes(stem));
}

const turndown = new TurndownService({
  headingStyle: 'atx',
  codeBlockStyle: 'fenced',
  bulletListMarker: '-',
  emDelimiter: '_',
});
turndown.use(gfm);
// Keep heading ids, so a diff shows when an anchor this repository links to
// (`…/IntegrationV2ClaimsCreate#cargopointaddress`) disappears or is renamed.
turndown.addRule('headingWithAnchor', {
  filter: (node) => /^H[1-6]$/.test(node.nodeName) && node.getAttribute('id'),
  replacement: (content, node) => {
    const level = Number(node.nodeName[1]);
    const text = content.replace(/\s+/g, ' ').trim();
    return `\n\n${'#'.repeat(level)} ${text} <a id="${node.getAttribute('id')}"></a>\n\n`;
  },
});
// Diplodoc renders a <summary> as a block; keep it as one line, bold unless it already carries
// emphasis (`**Example**`, `**Type**: object`) — wrapping those would emit `****`.
turndown.addRule('summary', {
  filter: 'summary',
  replacement: (content) => {
    const text = content.trim();
    return `\n\n${text.includes('**') ? text : `**${text}**`}\n\n`;
  },
});

/// The GFM plugin keeps a table as raw HTML when any cell holds a list, a heading, a rule or a
/// quote — and most schema tables on the Yandex reference pages list enum values in a cell.
/// A GFM cell can only hold inline content, so rewrite those blocks as inline equivalents
/// first: list items become `<br>`-separated `- item` lines (indented when nested), headings
/// become bold, rules disappear, quotes are unwrapped. Wording is untouched.
/// Diplodoc shows a required property with a CSS-drawn asterisk on
/// `<em class="json-schema-required">name</em>`, which Markdown would drop — and required-ness
/// is precisely what `REVIEW.md` asks spec edits to cite. Spell it out as `name` _(required)_.
function markRequiredProperties(document) {
  for (const name of Array.from(document.querySelectorAll('.json-schema-required'))) {
    const marker = document.createElement('span');
    marker.appendChild(document.createTextNode(' (required)'));
    name.parentNode.insertBefore(marker, name.nextSibling);
  }
}

// Domino implements the classic DOM only — no `append`/`replaceWith`, and NodeLists that are
// array-like rather than iterable — hence `appendChild`, `replaceChild` and `Array.from`.
function flattenTableCells(document) {
  for (const cell of Array.from(document.querySelectorAll('td, th'))) {
    // Innermost lists first, so an outer item's text already contains its flattened children.
    for (const list of Array.from(cell.querySelectorAll('ul, ol')).reverse()) {
      const depth = ancestors(list).filter((node) => /^(UL|OL)$/.test(node.nodeName)).length;
      const items = Array.from(list.childNodes).filter((child) => child.nodeName === 'LI');
      const replacement = document.createElement('span');
      items.forEach((item, index) => {
        const marker = list.nodeName === 'OL' ? `${index + 1}.` : '-';
        replacement.appendChild(document.createElement('br'));
        replacement.appendChild(document.createTextNode(`${'  '.repeat(depth)}${marker} `));
        moveChildren(item, replacement, { unwrapParagraphs: true });
      });
      list.parentNode.replaceChild(replacement, list);
    }
    for (const heading of Array.from(cell.querySelectorAll('h1, h2, h3, h4, h5, h6'))) {
      const strong = document.createElement('strong');
      moveChildren(heading, strong);
      heading.parentNode.replaceChild(strong, heading);
    }
    for (const rule of Array.from(cell.querySelectorAll('hr'))) rule.parentNode.removeChild(rule);
    for (const quote of Array.from(cell.querySelectorAll('blockquote'))) {
      const span = document.createElement('span');
      moveChildren(quote, span);
      quote.parentNode.replaceChild(span, quote);
    }
  }

  function ancestors(node) {
    const result = [];
    for (let parent = node.parentNode; parent; parent = parent.parentNode) result.push(parent);
    return result;
  }

  // Moves every child of `from` to the end of `to`. With `unwrapParagraphs`, a <p> child is
  // replaced by its contents — inside a list item it would otherwise end the cell's line.
  function moveChildren(from, to, { unwrapParagraphs = false } = {}) {
    while (from.firstChild) {
      const child = from.firstChild;
      if (unwrapParagraphs && child.nodeName === 'P') {
        moveChildren(child, to);
        from.removeChild(child);
      } else {
        to.appendChild(child);
      }
    }
  }
}

/// Converts extracted HTML to the canonical Markdown body: two captures of an unchanged page
/// must hash identically, so whitespace is normalized. Text is otherwise verbatim.
export function toMarkdown(html) {
  const document = domino.createDocument(`<!doctype html><html><body>${html}</body></html>`);
  markRequiredProperties(document);
  flattenTableCells(document);
  return `${turndown.turndown(document.body)
    .normalize('NFC')
    .replace(/ /g, ' ')
    .replace(/[ \t]+$/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim()}\n`;
}

/// Writes `<outDir>/<stem>.md` — YAML front matter (Source, Captured, Title, SHA-256 of the
/// body), a blank line, the body — and returns the body's SHA-256. The hash covers the body
/// only, so `upstream-diff.sh` can tell a content change from a new capture date.
export async function writeCapture(outDir, { stem, url, title, html, captured = new Date() }) {
  const body = toMarkdown(html);
  const sha256 = createHash('sha256').update(body, 'utf8').digest('hex');
  const frontMatter = [
    '---',
    `Source: ${url}`,
    `Captured: ${captured.toISOString().slice(0, 10)}`,
    `Title: ${JSON.stringify(title)}`,
    `SHA-256: ${sha256}`,
    '---',
  ].join('\n');
  await mkdir(outDir, { recursive: true });
  await writeFile(join(outDir, `${stem}.md`), `${frontMatter}\n\n${body}`);
  return sha256;
}

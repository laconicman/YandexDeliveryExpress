#!/usr/bin/env node
// Converts a snapshot taken by `extract.js` in a browser this repository does not drive —
// an agent's browser, or DevTools by hand — into cache files, through the same `markdown.mjs`
// as `capture.mjs` (issue #17).
//
// Usage: node import-snapshot.mjs --pages <pages.txt> --out <dir> <snapshot.json>
//
// The snapshot is a JSON array of `{ stem, title, html, captured? }`, one per page, where
// `title` and `html` are `extract.js`'s result and `captured` is an ISO date. Each stem must
// be in `pages.txt`; the Source written is the URL listed there, not wherever the browser
// was redirected.

import { readFile } from 'node:fs/promises';
import { parseArgs } from 'node:util';
import { readPages, writeCapture } from './markdown.mjs';

const { values: options, positionals: [snapshotPath] } = parseArgs({
  options: { pages: { type: 'string' }, out: { type: 'string' } },
  allowPositionals: true,
});
if (!options.pages || !options.out || !snapshotPath) {
  console.error('usage: import-snapshot.mjs --pages <pages.txt> --out <dir> <snapshot.json>');
  process.exit(64);
}

const snapshot = JSON.parse(await readFile(snapshotPath, 'utf8'));
const pages = await readPages(options.pages, snapshot.map(({ stem }) => stem));
for (const { stem, title, html, captured } of snapshot) {
  const { url } = pages.find((page) => page.stem === stem);
  const date = captured ? new Date(captured) : new Date();
  console.log(`${await writeCapture(options.out, { stem, url, title, html, captured: date })}  ${stem}.md`);
}

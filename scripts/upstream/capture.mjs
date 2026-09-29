#!/usr/bin/env node
// Captures the pages in `Upstream/yandex-docs/pages.txt` with a real browser (issue #17).
// The pages are rendered by JavaScript and refuse a plain HTTP fetch, so this drives Chrome
// through Playwright (https://playwright.dev/docs/library), runs `extract.js` in each
// rendered page, and writes the result through `markdown.mjs`.
//
// Usage: node capture.mjs --pages <pages.txt> --out <dir> [--selector <css>] [stem ...]
//
// Environment:
//   UPSTREAM_BROWSER_CHANNEL  Playwright channel. Default `chrome` — the installed Google
//                             Chrome, so nothing is downloaded and Yandex sees an ordinary
//                             browser. `chromium` uses Playwright's own build.
//   UPSTREAM_BROWSER_PATH     Explicit browser executable; overrides the channel.
//   UPSTREAM_HEADED=1         Show the window, e.g. to pass a captcha by hand.

import { readFile } from 'node:fs/promises';
import { parseArgs } from 'node:util';
import { chromium } from 'playwright-core';
import { readPages, writeCapture } from './markdown.mjs';

const { values: options, positionals: onlyStems } = parseArgs({
  options: { pages: { type: 'string' }, out: { type: 'string' }, selector: { type: 'string' } },
  allowPositionals: true,
});
if (!options.pages || !options.out) {
  console.error('usage: capture.mjs --pages <pages.txt> --out <dir> [--selector <css>] [stem ...]');
  process.exit(64);
}

const pages = await readPages(options.pages, onlyStems);
const extract = await readFile(new URL('./extract.js', import.meta.url), 'utf8');

const browser = await chromium.launch({
  headless: process.env.UPSTREAM_HEADED !== '1',
  ...(process.env.UPSTREAM_BROWSER_PATH
    ? { executablePath: process.env.UPSTREAM_BROWSER_PATH }
    : { channel: process.env.UPSTREAM_BROWSER_CHANNEL ?? 'chrome' }),
});
const context = await browser.newContext({ locale: 'ru-RU' });

const failures = [];
for (const { stem, url } of pages) {
  const page = await context.newPage();
  try {
    const response = await page.goto(url, { waitUntil: 'networkidle', timeout: 60_000 });
    if (response && !response.ok()) throw new Error(`HTTP ${response.status()}`);
    const { title, html } = await page.evaluate(
      `(${extract.trim()})(${JSON.stringify({ selector: options.selector })})`,
    );
    console.log(`${await writeCapture(options.out, { stem, url, title, html })}  ${stem}.md`);
  } catch (error) {
    failures.push(stem);
    console.error(`FAILED ${stem} (${url}): ${error.message}`);
  } finally {
    await page.close();
  }
}
await browser.close();
process.exit(failures.length ? 1 : 0);

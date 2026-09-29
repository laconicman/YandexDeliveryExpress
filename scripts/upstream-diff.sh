#!/usr/bin/env bash
# Re-captures the upstream Yandex pages and diffs them against the cache in
# Upstream/yandex-docs/ (issue #17). Yandex does not version these pages, so this is how a
# change to a field's meaning, a status word, or the «no test environment» wording surfaces
# as a diff to read instead of a surprise in a live call.
#
# Usage:
#   scripts/upstream-diff.sh [--write] [stem ...]
#
#   (no flags)  Capture into a temporary directory and report. Exit 0 when nothing changed,
#               1 when a page changed or is new, 2 when a capture failed.
#   --write     Also copy changed and new pages into the cache, for review with `git diff`.
#   stem ...    Only these pages (file stems from Upstream/yandex-docs/pages.txt).
#
# Needs Node 20+ and Google Chrome; see Upstream/yandex-docs/README.md for other browsers.
# The comparison uses the SHA-256 of each page's body recorded in its front matter, so a
# re-capture of an unchanged page is not a change even though its Captured date differs.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache="$repo_root/Upstream/yandex-docs"
tool="$repo_root/scripts/upstream"

write=false
if [[ "${1:-}" == "--write" ]]; then
  write=true
  shift
fi

if [[ ! -d "$tool/node_modules" ]]; then
  npm ci --prefix "$tool" --no-audit --no-fund >&2
fi

fresh="$(mktemp -d)"
trap 'rm -rf "$fresh"' EXIT

capture_status=0
node "$tool/capture.mjs" --pages "$cache/pages.txt" --out "$fresh" "$@" >/dev/null || capture_status=$?

# The body is everything after the closing `---` of the front matter and its blank line.
body() { awk 'front < 2 { if ($0 == "---") front++; next } !started && $0 == "" { started = 1; next } { started = 1; print }' "$1"; }
body_sha() { sed -n 's/^SHA-256: //p' "$1" | head -n 1; }

changed=0
for captured in "$fresh"/*.md; do
  [[ -e "$captured" ]] || break
  name="$(basename "$captured")"
  cached="$cache/$name"
  if [[ ! -f "$cached" ]]; then
    echo "new        $name"
  elif [[ "$(body_sha "$captured")" == "$(body_sha "$cached")" ]]; then
    echo "unchanged  $name"
    continue
  else
    echo "changed    $name"
    diff -u -L "cached/$name" -L "captured/$name" <(body "$cached") <(body "$captured") || true
  fi
  changed=1
  if $write; then cp "$captured" "$cached"; fi
done

if (( capture_status != 0 )); then
  echo "Some pages failed to capture; see the messages above." >&2
  exit 2
fi
if (( changed )) && ! $write; then
  echo "Upstream changed. Re-run with --write, review with git diff, and re-read the questions in Upstream/yandex-docs/README.md." >&2
  exit 1
fi

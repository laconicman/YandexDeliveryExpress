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
#               1 when a page changed, moved or is new, 2 when a capture failed.
#   --write     Also copy changed, moved and new pages into the cache, for review with
#               `git diff`. The exit status is the same as without it.
#   stem ...    Only these pages (file stems from Upstream/yandex-docs/pages.txt).
#
# Needs Node 20+ and Google Chrome; see Upstream/yandex-docs/README.md for other browsers.
# A page counts as unchanged when both its body and its Source URL match the cache; the
# Captured date is ignored, so re-capturing an unchanged page is quiet. Bodies are hashed as
# they are on disk, so a hand edit to a cached body is caught, not masked by the SHA-256
# recorded in its front matter.
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

# The body is everything after the front matter's closing `---` and the blank line after it,
# byte for byte: a line-oriented tool such as awk would re-terminate the last line and hide an
# edit that only removes the final newline. Perl ships with macOS and every Linux.
body() { perl -0777 -pe 's/\A---\n.*?\n---\n\n//s' "$1"; }
field() { sed -n "s/^$2: //p" "$1" | head -n 1; }
sha256() { if command -v shasum >/dev/null; then shasum -a 256; else sha256sum; fi | cut -d' ' -f1; }

changed=0
for captured in "$fresh"/*.md; do
  [[ -e "$captured" ]] || break
  name="$(basename "$captured")"
  cached="$cache/$name"
  if [[ ! -f "$cached" ]]; then
    echo "new        $name"
  else
    cached_sha="$(body "$cached" | sha256)"
    if [[ "$cached_sha" != "$(field "$cached" SHA-256)" ]]; then
      echo "note       $name: cached body does not match its recorded SHA-256 (edited by hand?)" >&2
    fi
    if [[ "$cached_sha" == "$(body "$captured" | sha256)" ]]; then
      if [[ "$(field "$cached" Source)" == "$(field "$captured" Source)" ]]; then
        echo "unchanged  $name"
        continue
      fi
      echo "moved      $name: $(field "$cached" Source) -> $(field "$captured" Source)"
    else
      echo "changed    $name"
      diff -u -L "cached/$name" -L "captured/$name" <(body "$cached") <(body "$captured") || true
    fi
  fi
  changed=1
  if $write; then cp "$captured" "$cached"; fi
done

if (( capture_status != 0 )); then
  echo "Some pages failed to capture; see the messages above." >&2
  exit 2
fi
if (( changed )); then
  if $write; then
    echo "Cache updated. Review with git diff, and re-read the questions in Upstream/yandex-docs/README.md." >&2
  else
    echo "Upstream changed. Re-run with --write, review with git diff, and re-read the questions in Upstream/yandex-docs/README.md." >&2
  fi
  exit 1
fi

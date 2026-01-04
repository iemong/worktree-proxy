#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

if ! command -v gh >/dev/null 2>&1; then
  echo "[error] gh (GitHub CLI) is not installed."
  exit 1
fi

TAG=${RELEASE_TAG:-}
if [[ -z "$TAG" ]]; then
  echo "[error] RELEASE_TAG is required (e.g. v1.0.0)."
  exit 1
fi

TITLE=${RELEASE_TITLE:-$TAG}
OUT_DIR=${OUT_DIR:-"$ROOT_DIR/release"}

if [[ ! -d "$OUT_DIR" ]]; then
  echo "[error] Release directory not found: $OUT_DIR"
  exit 1
fi

notes_file=$(mktemp)
cat <<NOTES > "$notes_file"
Release $TAG

Artifacts are in $OUT_DIR.
NOTES

set +e
existing=$(gh release view "$TAG" --json tagName -q .tagName 2>/dev/null)
set -e

if [[ -n "$existing" ]]; then
  echo "[info] Release $TAG already exists. Uploading assets..."
  gh release upload "$TAG" "$OUT_DIR"/* --clobber
else
  gh release create "$TAG" "$OUT_DIR"/* --title "$TITLE" --notes-file "$notes_file"
fi

rm -f "$notes_file"

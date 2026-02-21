#!/usr/bin/env bash
# KIRIKAE CLI - Local dev proxy environment manager
# Usage: kirikae.sh <command> [args...]
#
# Commands:
#   status                      Show current active environment
#   list                        List all registered environments
#   add <label> <url>           Register a new environment
#   switch <id>                 Switch active environment by ID
#   switch-url <url>            Switch active environment by URL
#   rename <id> <new-label>     Rename an environment (keeps URL)
#   update <id> <label> <url>   Update an environment's label and URL
#   delete <id>                 Delete an environment

set -euo pipefail

ADMIN_PORT="${PROXY_ADMIN_PORT:-4000}"
BASE_URL="http://localhost:${ADMIN_PORT}"

cmd="${1:-help}"
shift || true

case "$cmd" in
  status)
    curl -sf "${BASE_URL}/status" | jq .
    ;;

  list|ls)
    curl -sf "${BASE_URL}/targets" | jq .
    ;;

  add)
    label="${1:?Usage: kirikae.sh add <label> <url>}"
    url="${2:?Usage: kirikae.sh add <label> <url>}"
    curl -sf -X POST "${BASE_URL}/targets" \
      -H 'Content-Type: application/json' \
      -d "{\"label\":\"${label}\",\"url\":\"${url}\"}" | jq .
    ;;

  switch|sw)
    id="${1:?Usage: kirikae.sh switch <id>}"
    curl -sf -X POST "${BASE_URL}/switch" \
      -H 'Content-Type: application/json' \
      -d "{\"targetId\":\"${id}\"}" | jq .
    ;;

  switch-url)
    url="${1:?Usage: kirikae.sh switch-url <url>}"
    curl -sf -X POST "${BASE_URL}/switch" \
      -H 'Content-Type: application/json' \
      -d "{\"target\":\"${url}\"}" | jq .
    ;;

  rename)
    id="${1:?Usage: kirikae.sh rename <id> <new-label>}"
    new_label="${2:?Usage: kirikae.sh rename <id> <new-label>}"
    # Fetch current URL to preserve it
    current_url=$(curl -sf "${BASE_URL}/targets" | jq -r ".environments[] | select(.id==\"${id}\") | .url")
    if [ -z "$current_url" ] || [ "$current_url" = "null" ]; then
      echo "Error: Environment '${id}' not found." >&2
      exit 1
    fi
    curl -sf -X PUT "${BASE_URL}/targets/${id}" \
      -H 'Content-Type: application/json' \
      -d "{\"label\":\"${new_label}\",\"url\":\"${current_url}\"}" | jq .
    ;;

  update)
    id="${1:?Usage: kirikae.sh update <id> <label> <url>}"
    label="${2:?Usage: kirikae.sh update <id> <label> <url>}"
    url="${3:?Usage: kirikae.sh update <id> <label> <url>}"
    curl -sf -X PUT "${BASE_URL}/targets/${id}" \
      -H 'Content-Type: application/json' \
      -d "{\"label\":\"${label}\",\"url\":\"${url}\"}" | jq .
    ;;

  delete|rm)
    id="${1:?Usage: kirikae.sh delete <id>}"
    curl -sf -X DELETE "${BASE_URL}/targets/${id}" | jq .
    ;;

  help|--help|-h)
    sed -n '2,10p' "$0" | sed 's/^# \?//'
    ;;

  *)
    echo "Unknown command: ${cmd}" >&2
    echo "Run 'kirikae.sh help' for usage." >&2
    exit 1
    ;;
esac

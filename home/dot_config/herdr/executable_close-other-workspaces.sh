#!/bin/sh

set -u

workspace_json="$(herdr workspace list)" || {
  printf 'Could not list Herdr workspaces.\n'
  exit 1
}

current="$(
  printf '%s\n' "$workspace_json" |
    /usr/bin/jq -r 'first(.result.workspaces[] | select(.focused == true) | .workspace_id) // empty'
)"

if [ -z "$current" ]; then
  printf 'Could not determine the current workspace; nothing was closed.\n'
  exit 1
fi

others="$(
  printf '%s\n' "$workspace_json" |
    /usr/bin/jq -r --arg current "$current" \
      '.result.workspaces[] | select(.workspace_id != $current) | .workspace_id'
)"

if [ -z "$others" ]; then
  printf 'There are no other workspaces to close.\n'
  printf 'Press Enter to dismiss. '
  read -r _
  exit 0
fi

count="$(printf '%s\n' "$others" | /usr/bin/awk 'NF { count++ } END { print count + 0 }')"
printf 'Close %s workspace(s), keeping %s? [y/N] ' "$count" "$current"
read -r answer

case "$answer" in
  y|Y|yes|YES)
    ;;
  *)
    printf 'Cancelled.\n'
    exit 0
    ;;
esac

failed=0
for workspace_id in $others; do
  printf 'Closing %s... ' "$workspace_id"
  if herdr workspace close "$workspace_id" >/dev/null; then
    printf 'done\n'
  else
    printf 'failed\n'
    failed=$((failed + 1))
  fi
done

if [ "$failed" -ne 0 ]; then
  printf '%s workspace(s) could not be closed. Press Enter to dismiss. ' "$failed"
  read -r _
  exit 1
fi

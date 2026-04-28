#!/usr/bin/env bash
# Usage: invoked by hook on Edit of library/scratchpads/*.md
# Reads stdin (hook JSON input), extracts edited file path, truncates to ≤30 lines if exceeded.

set -euo pipefail

# Hook gives JSON on stdin
HOOK_INPUT=$(cat)

# Extract file path from tool_input.file_path
FILE=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

# Only operate on humanpowers scratchpads
case "$FILE" in
  */library/scratchpads/*.md) ;;
  *) exit 0 ;;
esac

LINES=$(wc -l < "$FILE")
LIMIT=30

if [ "$LINES" -le "$LIMIT" ]; then
  exit 0
fi

# Truncate: keep last LIMIT lines (most recent scratchpad entries)
TMP=$(mktemp)
tail -n "$LIMIT" "$FILE" > "$TMP"
mv "$TMP" "$FILE"

# Emit warning to stderr (visible to Claude as additional context per hook protocol)
echo "Truncated $FILE to last $LIMIT lines (was $LINES)" >&2

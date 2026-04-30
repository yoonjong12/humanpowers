#!/usr/bin/env bash
# Usage: get-invariant.sh <item-id> [workspace-root]
# Extracts a specific criterion-N / invariant-N / out-of-scope-N / open-question-N
# item from problem.md without reading the full file.
# Output: the matching line plus up to 5 continuation lines.
set -e
ITEM=${1:?usage: get-invariant.sh <item-id> [workspace-root]}
WS=${2:-$(pwd)}
FILE="$WS/.humanpowers/problem.md"

[ -f "$FILE" ] || { echo "not found: $FILE" >&2; exit 1; }

awk "/\*\*${ITEM}\*\*/{found=1; print; next} found && /^- \*\*[a-z]/{exit} found && /^## /{exit} found{print}" "$FILE"

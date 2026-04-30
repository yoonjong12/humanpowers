#!/usr/bin/env bash
# Usage: parse-answers.sh <task-id> [workspace-root]
# Extracts Developer answer blocks from round1.md without reading the full file.
# Output: one ===Q-ID header per answered Q, followed by the full answer block.
set -e
TASK=${1:?usage: parse-answers.sh <task-id> [workspace-root]}
WS=${2:-$(pwd)}
FILE="$WS/.humanpowers/tasks/$TASK/round1.md"

[ -f "$FILE" ] || { echo "not found: $FILE" >&2; exit 1; }

awk '
  /^### Q-/ {
    if (qid != "" && answer != "") { printf "===%s\n%s\n\n", qid, answer }
    qid = substr($0, 5)
    answer = ""
    capture = 0
    next
  }
  /^\*\*Developer answer:\*\*/ { capture = 1; answer = $0; next }
  capture && /^---$/ { capture = 0; next }
  capture { answer = answer "\n" $0 }
  END { if (qid != "" && answer != "") { printf "===%s\n%s\n", qid, answer } }
' "$FILE"

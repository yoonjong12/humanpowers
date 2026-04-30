#!/usr/bin/env bash
# Usage: get-task.sh <task-id> [workspace-root]
# Extracts a single task-N section from tasks.md without reading the full file.
# Output: the ## task-N: ... block until the next ## task- or EOF.
set -e
TASK=${1:?usage: get-task.sh <task-id> [workspace-root]}
WS=${2:-$(pwd)}
FILE="$WS/.humanpowers/tasks.md"

[ -f "$FILE" ] || { echo "not found: $FILE" >&2; exit 1; }

awk "/^## ${TASK}:/{found=1; print; next} found && /^## task-[0-9]/{exit} found{print}" "$FILE"

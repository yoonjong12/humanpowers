#!/usr/bin/env bash
# Usage: get-step.sh <task-id> <step-n> [workspace-root]
# Extracts a single Step N block from plan.md without reading the full file.
# Output: the - [ ] **Step N:** block until the next step or EOF.
set -e
TASK=${1:?usage: get-step.sh <task-id> <step-n> [workspace-root]}
STEP=${2:?usage: get-step.sh <task-id> <step-n> [workspace-root]}
WS=${3:-$(pwd)}
FILE="$WS/.humanpowers/tasks/$TASK/plan.md"

[ -f "$FILE" ] || { echo "not found: $FILE" >&2; exit 1; }

awk "/\*\*Step ${STEP}:/{found=1; print; next} found && /\*\*Step [0-9]+:/{exit} found{print}" "$FILE"

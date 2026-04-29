#!/usr/bin/env bash
# Usage: scripts/check-state.sh [workspace-path]
# Echoes current phase + target_repo + counts. Exit 0 if valid, 1 if missing/invalid.

set -euo pipefail

WS="${1:-$(pwd)}"
STATE="$WS/.humanpowers/state.json"

if [ ! -f "$STATE" ]; then
  echo "ERROR: No state.json at $STATE" >&2
  exit 1
fi

# Required fields per humanpowers-design.md
for field in phase target_repo workspace_kind tasks_total tasks_quiz_done tasks_built tasks_verified; do
  if ! jq -e "has(\"$field\")" "$STATE" >/dev/null 2>&1; then
    echo "ERROR: state.json missing required field '$field'. Workspace from a prior plugin version detected. Delete .humanpowers/ and re-init with /humanpowers." >&2
    exit 1
  fi
done

PHASE=$(jq -r .phase "$STATE")
TARGET=$(jq -r .target_repo "$STATE")
KIND=$(jq -r .workspace_kind "$STATE")
TASKS_TOTAL=$(jq -r .tasks_total "$STATE")
TASKS_QUIZ=$(jq -r .tasks_quiz_done "$STATE")
TASKS_BUILT=$(jq -r .tasks_built "$STATE")
TASKS_VER=$(jq -r .tasks_verified "$STATE")

cat <<EOF
phase: $PHASE
target_repo: $TARGET
workspace_kind: $KIND
tasks:
  total: $TASKS_TOTAL
  quiz-done: $TASKS_QUIZ
  built: $TASKS_BUILT
  verified: $TASKS_VER
EOF

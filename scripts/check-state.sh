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
for field in phase target_repo workspace_kind tfs_total tfs_quiz_done tfs_built tfs_verified; do
  if ! jq -e "has(\"$field\")" "$STATE" >/dev/null 2>&1; then
    echo "ERROR: state.json missing required field '$field'. v0.1.x workspace detected. Delete .humanpowers/ and re-init with /humanpowers." >&2
    exit 1
  fi
done

PHASE=$(jq -r .phase "$STATE")
TARGET=$(jq -r .target_repo "$STATE")
KIND=$(jq -r .workspace_kind "$STATE")
TFS_TOTAL=$(jq -r .tfs_total "$STATE")
TFS_QUIZ=$(jq -r .tfs_quiz_done "$STATE")
TFS_BUILT=$(jq -r .tfs_built "$STATE")
TFS_VER=$(jq -r .tfs_verified "$STATE")

cat <<EOF
phase: $PHASE
target_repo: $TARGET
workspace_kind: $KIND
tfs:
  total: $TFS_TOTAL
  quiz-done: $TFS_QUIZ
  built: $TFS_BUILT
  verified: $TFS_VER
EOF

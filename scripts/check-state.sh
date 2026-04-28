#!/usr/bin/env bash
# Usage: scripts/check-state.sh [workspace-path]
# Echoes current phase + counts. Exit 0 if state.json present, 1 if not.

set -euo pipefail

WS="${1:-$(pwd)}"
STATE="$WS/.humanpowers/state.json"

if [ ! -f "$STATE" ]; then
  echo "ERROR: No state.json at $STATE" >&2
  exit 1
fi

PHASE=$(jq -r .phase "$STATE")
TFS_TOTAL=$(jq -r .tfs_total "$STATE")
TFS_BS=$(jq -r .tfs_brainstormed "$STATE")
TFS_QUIZ=$(jq -r .tfs_quiz_done "$STATE")
TFS_BUILT=$(jq -r .tfs_built "$STATE")
TFS_VER=$(jq -r .tfs_verified "$STATE")
PROJECT=$(jq -r .project "$STATE")

cat <<EOF
project: $PROJECT
phase: $PHASE
tfs:
  total: $TFS_TOTAL
  brainstorm-done: $TFS_BS
  quiz-done: $TFS_QUIZ
  built: $TFS_BUILT
  verified: $TFS_VER
EOF

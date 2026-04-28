#!/usr/bin/env bash
# Usage: scripts/update-state.sh <workspace> <field> <value>
# E.g.: scripts/update-state.sh ~/humanpowers/proj phase quiz-done

set -euo pipefail

WS="${1:?workspace path required}"
FIELD="${2:?field name required}"
VALUE="${3:?value required}"

STATE="$WS/.humanpowers/state.json"
[ -f "$STATE" ] || { echo "ERROR: $STATE not found"; exit 1; }

# Use jq to update field. Numeric fields stay numeric, strings stay strings.
TMP=$(mktemp)

# Determine if value is numeric
if [[ "$VALUE" =~ ^-?[0-9]+$ ]]; then
  jq ".${FIELD} = ${VALUE}" "$STATE" > "$TMP"
else
  jq ".${FIELD} = \"${VALUE}\"" "$STATE" > "$TMP"
fi

mv "$TMP" "$STATE"
echo "Updated $FIELD = $VALUE"

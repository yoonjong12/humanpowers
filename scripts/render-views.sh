#!/usr/bin/env bash
# Usage: scripts/render-views.sh [workspace-path]
# Reads tfs.md → renders views/{macro,spec,progress}.md

set -euo pipefail

python3 -c "import yaml" 2>/dev/null || { echo "ERROR: PyYAML required. Install: pip install pyyaml"; exit 1; }

WS="${1:-$(pwd)}"
TFS="$WS/tfs.md"
VIEWS="$WS/views"

[ -f "$TFS" ] || { echo "ERROR: $TFS not found"; exit 1; }
mkdir -p "$VIEWS"

# Parse YAML-style TF entries from tfs.md
# Simple parser: finds "- id: TF-X" blocks until next "- id:" or EOF
# Outputs JSON-like structure for downstream rendering.

# Use python embedded for YAML-aware parsing
python3 <<EOF
import re, sys, os

tfs_path = "$TFS"
views_dir = "$VIEWS"

with open(tfs_path) as f:
    text = f.read()

# Find code block(s) under "## TFs" section
# Match all lines starting with "- id:" up to the end
import yaml
# Extract YAML from tfs.md — assume there's one or more "\`\`\`yaml ... \`\`\`" blocks under "## TFs"
yaml_blocks = re.findall(r'\`\`\`yaml\n(.*?)\n\`\`\`', text, re.DOTALL)
tfs = []
for block in yaml_blocks:
    parsed = yaml.safe_load(block) or []
    if isinstance(parsed, list):
        tfs.extend(parsed)

# Also accept inline "- id:" entries below "## TFs" (not in code blocks)
# Skip for v0 — require yaml blocks

if not tfs:
    print("WARN: no TFs found in tfs.md", file=sys.stderr)
    tfs = []

# Render macro view: concern × action_type
concerns = sorted({tf.get("concern", "uncategorized") for tf in tfs})
action_types = ["ui", "api", "data", "infra", "cross-cutting"]

with open(os.path.join(views_dir, "macro.md"), "w") as f:
    f.write("> Auto-rendered from tfs.md. Do NOT edit.\n\n")
    f.write("# Macro view — Concern × action_type\n\n")
    headers = "| Concern | " + " | ".join(action_types) + " |"
    f.write(headers + "\n")
    f.write("|" + "---|" * (len(action_types) + 1) + "\n")
    for c in concerns:
        row = [c]
        for at in action_types:
            ids = [tf["id"] for tf in tfs if tf.get("concern") == c and tf.get("action_type") == at]
            row.append(", ".join(ids) if ids else "—")
        f.write("| " + " | ".join(row) + " |\n")

# Render spec view: TF × fields
with open(os.path.join(views_dir, "spec.md"), "w") as f:
    f.write("> Auto-rendered from tfs.md. Do NOT edit.\n\n")
    f.write("# Spec view — TF × Fields\n\n")
    f.write("| TF | WHO | WHAT | VERIFY | NFR-local | STATUS |\n")
    f.write("|----|-----|------|--------|-----------|--------|\n")
    for tf in tfs:
        nfr = "; ".join(tf.get("nfr_local") or [])
        f.write(f"| {tf.get('id', '?')} | {tf.get('who', '')} | {tf.get('what', '')} | {tf.get('verify_form', '')} | {nfr} | {tf.get('status', '')} |\n")

# Render progress view: TF × stage
with open(os.path.join(views_dir, "progress.md"), "w") as f:
    f.write("> Auto-rendered from tfs.md. Do NOT edit.\n\n")
    f.write("# Progress view — TF × Stage\n\n")
    stages = ["brainstorm-done", "quiz-done", "designed", "built", "verified"]
    f.write("| TF | " + " | ".join(stages) + " |\n")
    f.write("|----|" + "---|" * len(stages) + "\n")
    for tf in tfs:
        row = [tf.get("id", "?")]
        s = tf.get("status", "")
        # Mark progress: each stage ≤ status = ✓
        order = {"brainstorm-done": 1, "quiz-done": 2, "designed": 3, "built": 4, "verified": 5}
        s_n = order.get(s, 0)
        for stage in stages:
            row.append("✓" if order.get(stage, 99) <= s_n else "—")
        f.write("| " + " | ".join(row) + " |\n")

print(f"Rendered {len(tfs)} TFs to {views_dir}/{{macro,spec,progress}}.md")
EOF

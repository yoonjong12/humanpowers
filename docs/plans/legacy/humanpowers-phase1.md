# humanpowers Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build humanpowers plugin Phase 1 MVP — independent repo fork of superpowers with boss-articulation enforcement, TF model, matrix views, and Quiz module. End state: boss can run E2E flow (brainstorm → quiz → design → build → verify → finish) on a generic project using only `/humanpowers:*` commands.

**Architecture:** Heavy fork of superpowers content as baseline → rebrand to `humanpowers` namespace → modify 7 skills with boss-articulation principles → add 4 new skills (quiz, scaffold, operate, review) + 1 dispatcher → add templates/examples/scripts/hooks. Independent git repo at `github.com/yoonjong12/humanpowers`. License = MIT (with superpowers attribution).

**Tech Stack:** Markdown (skills, docs, templates), Bash scripts (state checks, view rendering, shelf truncation), JSON (plugin.json, state.json, hooks.json). No Python required for Phase 1.

---

## Reference paths

- Spec: `/Users/jay/code/user/humanpowers/docs/specs/2026-04-28-humanpowers-design.md`
- Plugin code root: `/Users/jay/code/user/humanpowers/`
- Source plugin (for baseline copy): `/Users/jay/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`
- Test workspace (will be created during Task 20): `~/humanpowers/_self-test/`

## Spec Updates Needed

**Found during plan writing**: superpowers has 14 skills, not 13. Missing from spec table 3.2 = `writing-skills`. Add it before implementation begins.

- [ ] **Pre-task: Patch spec to include `writing-skills`**

```bash
# Add row to spec section 3.2 table (between using-superpowers and scaffold)
```

Edit `/Users/jay/code/user/humanpowers/docs/specs/2026-04-28-humanpowers-design.md` Section 3.2 table — add row:

```
| `writing-skills` | Light | Triggers/text rebrand — humanpowers skill creation guide |
```

Also update Section 3.1 "13 skill" → "14 skill". Update Phase 1 Step 5 to include writing-skills.

Commit:
```bash
cd /Users/jay/code/user/humanpowers
git add docs/specs/2026-04-28-humanpowers-design.md
git commit -m "spec: add missing writing-skills to fork list"
```

---

## File Structure

End state of `/Users/jay/code/user/humanpowers/`:

```
humanpowers/
├── .claude-plugin/
│   └── plugin.json                   # name: humanpowers
├── LICENSE                           # MIT (own + superpowers attribution)
├── README.md                         # identity + attribution + usage
├── docs/
│   ├── specs/
│   │   └── 2026-04-28-humanpowers-design.md   (already exists)
│   └── plans/
│       └── 2026-04-28-humanpowers-phase1.md   (this file)
├── skills/
│   ├── humanpowers/SKILL.md          # NEW dispatcher (single entry)
│   ├── brainstorming/SKILL.md        # Heavy modify
│   ├── writing-plans/SKILL.md        # Heavy modify
│   ├── verification-before-completion/SKILL.md   # Heavy modify
│   ├── executing-plans/SKILL.md      # Medium modify
│   ├── finishing-a-development-branch/SKILL.md   # Medium modify
│   ├── subagent-driven-development/SKILL.md      # Light modify
│   ├── dispatching-parallel-agents/SKILL.md      # Light modify
│   ├── test-driven-development/SKILL.md          # As-is rebrand
│   ├── using-git-worktrees/SKILL.md              # As-is rebrand
│   ├── systematic-debugging/SKILL.md             # As-is rebrand
│   ├── requesting-code-review/SKILL.md           # As-is rebrand
│   ├── receiving-code-review/SKILL.md            # As-is rebrand
│   ├── writing-skills/SKILL.md                   # Light modify
│   ├── using-humanpowers/SKILL.md                # Renamed from using-superpowers
│   ├── quiz/                                     # NEW
│   │   └── SKILL.md
│   ├── scaffold/                                 # NEW
│   │   └── SKILL.md
│   ├── operate/                                  # NEW
│   │   └── SKILL.md
│   └── review/                                   # NEW
│       └── SKILL.md
├── references/
│   ├── templates/
│   │   ├── quiz-template.md
│   │   ├── response-d1-template.md
│   │   ├── response-d2-template.md
│   │   ├── discussion-template.md
│   │   └── critique-axes.md
│   └── examples/
│       ├── README.md
│       ├── quiz-ui-example.md
│       ├── quiz-api-example.md
│       ├── quiz-data-example.md
│       ├── quiz-infra-example.md
│       ├── quiz-crosscut-example.md
│       └── d2-discussion-example.md
├── scripts/
│   ├── check-state.sh                # State router helper
│   ├── update-state.sh               # State transition
│   ├── render-views.sh               # tfs.md → views/*.md
│   └── shelf-truncate.sh             # Hook executor for ≤30 line enforcement
└── hooks/
    └── hooks.json                    # PostToolUse on Edit library/scratchpads/*
```

---

### Task 1: Plugin scaffold

**Files:**
- Create: `/Users/jay/code/user/humanpowers/.claude-plugin/plugin.json`
- Create: `/Users/jay/code/user/humanpowers/LICENSE`
- Create: `/Users/jay/code/user/humanpowers/README.md`
- Create: `/Users/jay/code/user/humanpowers/.gitignore`

- [ ] **Step 1: Verify working directory + clean state**

Run:
```bash
cd /Users/jay/code/user/humanpowers
pwd
git status
git log --oneline -5 2>/dev/null || echo "no commits yet"
```

Expected: pwd matches plugin root, status clean (no commits yet, just .git dir).

- [ ] **Step 2: Create .claude-plugin/plugin.json**

Create file `/Users/jay/code/user/humanpowers/.claude-plugin/plugin.json`:

```json
{
  "name": "humanpowers",
  "version": "0.1.0",
  "description": "Boss-articulation enforcement plugin. Forces lazy boss into design/quiz/verification dialogue. Forked from superpowers with TF model + matrix views + Quiz module.",
  "author": "yoonjong12",
  "homepage": "https://github.com/yoonjong12/humanpowers",
  "license": "MIT"
}
```

- [ ] **Step 3: Create LICENSE (MIT verbatim from superpowers + own copyright)**

Read upstream LICENSE first to get exact wording:
```bash
cat /Users/jay/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/LICENSE
```

Create `/Users/jay/code/user/humanpowers/LICENSE`:

```
MIT License

Copyright (c) 2025 Jesse Vincent (original superpowers, github.com/obra/superpowers)
Copyright (c) 2026 yoonjong12 (humanpowers fork, github.com/yoonjong12/humanpowers)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Create README.md**

Create `/Users/jay/code/user/humanpowers/README.md`:

```markdown
# humanpowers

> Forked from [superpowers](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent). humanpowers extends the design with boss-articulation enforcement, TF (Task Force) model, matrix views, and Quiz module.

## Identity

```
superpowers = AI 가 도와줌 (인간 부담 ↓)
humanpowers = 인간이 active 참여 강제 (인간 부담 ↑, 결과 정확 ↑)
```

## Goal

Force lazy boss to actively participate in design + verification + acceptance, preventing intent/implementation drift.

## Quick start

```
$ /humanpowers
```

Single entry point auto-routes by workspace state. See `docs/specs/` for full design.

## Phases

- **Phase 1 (current)**: 14 fork skills + 4 new (quiz/scaffold/operate/review) + dispatcher + Quiz module + matrix views.
- **Phase 2 (future)**: Auto signaling via SubagentStop hook + additionalContext.
- **Phase 3 (deferred)**: MCP server for true sync agent ↔ agent.

## License

MIT. See LICENSE.
```

- [ ] **Step 5: Create .gitignore**

Create `/Users/jay/code/user/humanpowers/.gitignore`:

```
.DS_Store
.humanpowers/state.json
.humanpowers/invocation-log.jsonl
node_modules/
*.swp
*.swo
```

- [ ] **Step 6: Verify plugin.json structure**

Run:
```bash
cd /Users/jay/code/user/humanpowers
cat .claude-plugin/plugin.json | python3 -m json.tool
ls -la
```

Expected: JSON valid, files present (plugin.json, LICENSE, README.md, .gitignore, docs/, .git/).

- [ ] **Step 7: Initial commit**

```bash
cd /Users/jay/code/user/humanpowers
git add .claude-plugin/ LICENSE README.md .gitignore
git commit -m "feat: scaffold humanpowers plugin (MIT, fork of superpowers)"
```

---

### Task 2: Bulk copy + rebrand 14 source skills

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/{14 source skill names}/` (each with all subfiles preserved)

Strategy: Copy entire skill dirs from source plugin → humanpowers/skills/. Rename `using-superpowers/` → `using-humanpowers/`. Rebrand text mentions of `superpowers` → `humanpowers` in copied files (excluding LICENSE attribution).

- [ ] **Step 1: Copy 13 skills as-is (no rename yet)**

```bash
SRC=/Users/jay/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills
DST=/Users/jay/code/user/humanpowers/skills

mkdir -p "$DST"
for skill in brainstorming dispatching-parallel-agents executing-plans finishing-a-development-branch receiving-code-review requesting-code-review subagent-driven-development systematic-debugging test-driven-development using-git-worktrees verification-before-completion writing-plans writing-skills; do
  cp -r "$SRC/$skill" "$DST/$skill"
done
```

- [ ] **Step 2: Copy + rename using-superpowers → using-humanpowers**

```bash
cp -r "$SRC/using-superpowers" "$DST/using-humanpowers"
```

- [ ] **Step 3: Verify 14 skill dirs present**

```bash
ls /Users/jay/code/user/humanpowers/skills/ | wc -l
```

Expected: 14.

```bash
ls /Users/jay/code/user/humanpowers/skills/
```

Expected output (sorted): `brainstorming dispatching-parallel-agents executing-plans finishing-a-development-branch receiving-code-review requesting-code-review subagent-driven-development systematic-debugging test-driven-development using-git-worktrees using-humanpowers verification-before-completion writing-plans writing-skills`

- [ ] **Step 4: Rebrand text — `superpowers` → `humanpowers` in skill markdown**

This is a global text replacement, but with care:
- Skill internal cross-references (e.g., "use superpowers:brainstorming") → "use humanpowers:brainstorming"
- DO NOT rewrite "Forked from superpowers" attribution in any future README — but skills don't have attribution lines, so safe to bulk replace.

```bash
cd /Users/jay/code/user/humanpowers/skills
# Replace in all .md files
find . -name "*.md" -type f -exec sed -i.bak 's/superpowers:/humanpowers:/g' {} \;
find . -name "*.md" -type f -exec sed -i.bak 's/Superpowers/Humanpowers/g' {} \;
find . -name "*.md" -type f -exec sed -i.bak 's/superpowers plugin/humanpowers plugin/g' {} \;
# Cleanup .bak files
find . -name "*.bak" -delete
```

- [ ] **Step 5: Spot check rebrand**

Run:
```bash
grep -r "superpowers" /Users/jay/code/user/humanpowers/skills/ | head -20
```

Expected: minimal remaining occurrences (probably 0). If any remain, inspect and decide whether to rebrand or keep.

If rebrand needed for additional patterns, add to Step 4 sed commands and re-run.

- [ ] **Step 6: Verify SKILL.md still parses**

```bash
for f in /Users/jay/code/user/humanpowers/skills/*/SKILL.md; do
  head -5 "$f" | grep -q "^---$" && echo "OK: $f" || echo "FAIL: $f"
done
```

Expected: all 14 = OK (frontmatter intact).

- [ ] **Step 7: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/
git commit -m "feat: copy + rebrand 14 superpowers skills as baseline"
```

---

### Task 3: Modify brainstorming (Heavy)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/brainstorming/SKILL.md`

Per spec section 3.2 + 7 (Quiz module hands off TO this skill output). Add: 비서 persona / TF extraction / matrix view output / type-aware VERIFY / NFR 2-layer.

- [ ] **Step 1: Read current brainstorming SKILL.md to find injection points**

Run:
```bash
wc -l /Users/jay/code/user/humanpowers/skills/brainstorming/SKILL.md
grep -n "^##" /Users/jay/code/user/humanpowers/skills/brainstorming/SKILL.md
```

Note section anchors — typically: Overview / Process / Documentation / etc.

- [ ] **Step 2: Add Persona section after frontmatter**

Insert after the closing `---` of frontmatter, before any `#` heading:

```markdown
## Persona — 비서 (Secretary)

You are a SECRETARY to the user (the BOSS). The boss is **lazy**. Your job:

- **Refuse vague answers.** "5 results" → "exactly 5 or ≥5?"
- **Push back specifics.** "fast" → "ms? seconds? quantify."
- **Narrow scope.** "homeshop site" → "pick one core value."
- **Block nodding.** Boss must articulate, not approve agent drafts.
- **One question at a time.** Bulk dump = banned.

The boss may resist. Persist. Specifics force articulation. Articulation prevents drift.
```

- [ ] **Step 3: Add TF extraction step after design section**

In the Process section, locate the step that says "Present design sections" or similar approval section. After that section's content, append:

```markdown
## Step N+1: TF Extraction

After design lock, decompose into TF (Task Force) atomic units.

For each TF, capture 5 fields + metadata:

```yaml
- id: TF-1a
  name: short descriptive name
  concern: boss-level scenario this serves
  action_type: ui | api | data | infra | cross-cutting
  who: persona (1 line)
  what: result/behavior (1-3 lines)
  why: value hypothesis (1 line)
  verify_form: gherkin | curl | sql | checklist | composite  # matches action_type
  nfr_local:
    - row-local NFR (e.g., "<500ms response")
  depends_on: []  # TF-ids this blocks on
  status: brainstorm-done
  mode: independent | facilitating | collaboration
```

Boss confirm each TF. Disagreements = revise spec, not skip.

Ask boss one TF at a time.

## Step N+2: Output to humanpowers workspace

Save outputs to `~/humanpowers/{project-name}/`:
- `boss.md` — Charter + invariants + persona
- `tfs.md` — TF list (5 fields above)
- `views/macro.md`, `views/spec.md`, `views/progress.md` — auto-rendered (run `scripts/render-views.sh`)

Set `.humanpowers/state.json` phase = `brainstorm-done`. Next phase = `quiz`.

## Step N+3: Hand off to quiz

Terminal state of brainstorming: invoke humanpowers:quiz skill (NOT writing-plans). Quiz module forces boss to articulate expected outputs per TF before any implementation plan.
```

- [ ] **Step 4: Add VERIFY type-aware section**

Add subsection under TF Extraction (Step N+1):

```markdown
### VERIFY form by action_type

| action_type | VERIFY form | Example |
|-------------|-------------|---------|
| ui | Gherkin (Given/When/Then) + Mock HTML/Figma | "Given user logged in / When click X / Then see Y" |
| api | cURL + expected JSON / OpenAPI example | `curl -X POST /api/x -d '{...}'` → `{status: 200, body: {...}}` |
| data | SQL assertion + sample row | `SELECT count(*) FROM x WHERE y = 'z'` → expect ≥1 |
| infra | Checklist + health curl | `[x] env SET / [x] curl /health → 200` |
| cross-cutting | Composite (all impacted TF VERIFY pass) | No standalone test |

Use this table when prompting boss for VERIFY content.
```

- [ ] **Step 5: Add NFR 2-layer section**

Add new subsection in Process:

```markdown
## NFR (Non-Functional Requirements) — 2 layers

**Layer 0 (Boss invariants)** — `boss.md` section. Default 4 categories:
- Security
- Data integrity
- Determinism
- Compliance

**Layer 1 (TF-local NFR)** — Per TF in `tfs.md`. Specific to one TF.

**Promotion rule**: When same NFR appears in **2+ TFs**, agent posts to `threads/promote-{nfr}.md`. Boss confirms = move to Layer 0.
```

- [ ] **Step 6: Update Documentation section**

Find the section about saving design doc. Replace with:

```markdown
## Documentation

humanpowers writes structured outputs (NOT a single design.md). Save to `~/humanpowers/{project-name}/`:

- `boss.md` — Charter, invariants, persona
- `tfs.md` — TF list with 5 fields each
- `views/{macro,spec,progress}.md` — auto-rendered from tfs.md
- `.humanpowers/state.json` — phase tracking

After boss approval, commit. Next: humanpowers:quiz.
```

- [ ] **Step 7: Verify modified SKILL.md still has valid frontmatter**

```bash
head -10 /Users/jay/code/user/humanpowers/skills/brainstorming/SKILL.md
```

Expected: `---` frontmatter intact with name/description.

- [ ] **Step 8: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): add 비서 persona + TF extraction + matrix output + 2-layer NFR"
```

---

### Task 4: Modify writing-plans (Heavy)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/writing-plans/SKILL.md`

Per spec section 3.2: TF-unit plans + boss confirm gates + depends_on build order.

- [ ] **Step 1: Add TF-unit plan structure section**

Insert after the existing "Task Structure" section:

```markdown
## TF-unit Plan Structure (humanpowers extension)

In humanpowers, plans are organized by TF (Task Force), not by linear phases.

Each TF gets its own plan section:

```markdown
## TF-1a: 검색 UI (action_type: ui)

**Spec source**: `tfs.md#TF-1a`
**VERIFY (signed_off)**: `tfs/TF-1a/expected-outputs.md`
**depends_on**: []
**Boss confirm gate**: REQUIRED before Task 1 of this TF begins.

### Task 1: ...
### Task 2: ...
```

After all tasks for a TF complete, mark `status: built` in `tfs.md`. Run humanpowers:verification-before-completion before next TF.
```

- [ ] **Step 2: Add boss confirm gate guidance**

Find existing approval/gate language. Append:

```markdown
### Boss Confirm Gates (humanpowers principle)

Each TF plan MUST have:

1. **Pre-build gate**: Boss confirms TF spec + expected-outputs are signed_off. If not, abort and re-run quiz.
2. **Mid-build checkpoints**: After each Task in TF, boss has option to inspect (not required, but available).
3. **Post-build gate**: Run humanpowers:verification-before-completion → boss demo signoff. NO code-pass-only completion.

Gates are explicit. AI does NOT proceed past gate without boss action.
```

- [ ] **Step 3: Add depends_on build ordering section**

Append:

```markdown
## Build Order from depends_on

Read `tfs.md`. Compute topological order from `depends_on` field:

1. TFs with `depends_on: []` → can start immediately, parallel-eligible.
2. TFs with deps → wait until all deps `status: verified`.
3. Cycle in deps = abort, ask boss to break cycle.

Use humanpowers:dispatching-parallel-agents for parallel-eligible TFs.
```

- [ ] **Step 4: Update Documentation/save path**

Find existing "Save plans to" line. Replace with:

```markdown
**Save plans to:** `~/humanpowers/{project-name}/tfs/{TF-id}/build-plan.md`

One plan file per TF. Cross-TF coordination via `threads/*.md`.
```

- [ ] **Step 5: Verify + commit**

```bash
head -10 /Users/jay/code/user/humanpowers/skills/writing-plans/SKILL.md
cd /Users/jay/code/user/humanpowers
git add skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): TF-unit plan + boss confirm gates + depends_on order"
```

---

### Task 5: Modify verification-before-completion (Heavy)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/verification-before-completion/SKILL.md`

Per spec: code pass → boss demo signoff. action_type-specific demo forms.

- [ ] **Step 1: Add core principle replacement**

Insert at top of SKILL.md (after frontmatter):

```markdown
## Core principle (humanpowers replacement of superpowers verification)

**superpowers**: "All tests pass + types check + linter clean = verified."
**humanpowers**: "Boss watched the demo + signed off = verified. Code passes are necessary but NOT sufficient."

VERIFY = signed_off `tfs/{TF-id}/expected-outputs.md` from quiz phase.
```

- [ ] **Step 2: Add demo form per action_type**

Append:

```markdown
## Demo form by action_type

| action_type | Demo form for boss |
|-------------|-------------------|
| ui | Live click-through following Gherkin scenarios. Boss watches screen, confirms each Then clause. |
| api | Live cURL execution with response shown. Boss confirms HTTP code + body shape. |
| data | SQL query execution with row count + sample row dump. Boss confirms expected vs actual. |
| infra | Checklist walkthrough + health curl. Boss confirms each item. |
| cross-cutting | Composite — show all impacted TFs' demos pass. Boss confirms aggregate. |

Boss WATCHES the demo (or operates it themselves). Agent does NOT run demo silently then say "passed". Boss must SEE the result.
```

- [ ] **Step 3: Add explicit signoff step**

Append:

```markdown
## Signoff process

1. Agent prepares demo per `expected-outputs.md` Q list.
2. Agent runs demo with boss watching (or boss runs).
3. For each Q, boss says: PASS / FAIL / NEEDS REWORK.
4. All Q = PASS → mark TF `status: verified` in `tfs.md`.
5. Any FAIL → halt, return to writing-plans for re-build.
6. NEEDS REWORK → return to quiz to re-articulate that Q.
```

- [ ] **Step 4: Verify + commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/verification-before-completion/SKILL.md
git commit -m "feat(verification): boss demo signoff replaces code-pass; action_type-specific demo forms"
```

---

### Task 6: Modify executing-plans (Medium)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/executing-plans/SKILL.md`

Per spec: checkpoint demo verification.

- [ ] **Step 1: Add checkpoint demo section**

Insert after existing checkpoint/review section:

```markdown
## humanpowers Checkpoints

After each TF Task completes, agent MUST:

1. Update `tfs/{TF-id}/build-plan.md` task checkbox to `[x]`.
2. Update `tfs.md` row status if appropriate.
3. **Optional boss demo**: If task is "user-visible" (creates UI element / API endpoint / data), offer boss a mini-demo. Boss can skip.
4. After ALL tasks in a TF complete, INVOKE humanpowers:verification-before-completion → mandatory boss demo signoff.

Skipping mandatory signoff = TF stays at `status: built`, NOT `verified`.
```

- [ ] **Step 2: Update next-skill handoff**

Find existing terminal state / next-skill instruction. Replace with:

```markdown
## Terminal state

After all tasks in a TF complete: invoke humanpowers:verification-before-completion. Do NOT mark TF verified independently.
```

- [ ] **Step 3: Verify + commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/executing-plans/SKILL.md
git commit -m "feat(executing-plans): mandatory verification handoff after each TF"
```

---

### Task 7: Modify finishing-a-development-branch (Medium)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/finishing-a-development-branch/SKILL.md`

Per spec: boss final acceptance + boss.md version bump.

- [ ] **Step 1: Add boss final acceptance section**

Insert after existing branch-finish steps:

```markdown
## humanpowers final acceptance

Before merge/PR/cleanup:

1. Verify ALL TFs in `tfs.md` have `status: verified`. If any not verified, halt.
2. Run `scripts/render-views.sh` — final views/*.md updated.
3. Show boss the `views/progress.md` matrix — all checkboxes filled.
4. Boss explicit signoff via AskUserQuestion:
   - "All TFs verified. Ready to finalize? PASS / HOLD / ABORT"
5. PASS → bump `boss.md` version (e.g., v1.0 → v1.1 minor or v2.0 major if pivot occurred).
6. Commit + tag git.
```

- [ ] **Step 2: Add version bump rules**

Append:

```markdown
## boss.md Version bump rules

Locate `boss.md` header `version: vX.Y`.

- **Minor (X.Y → X.Y+1)**: TF additions, non-structural edits, NFR additions.
- **Major (X.Y → X+1.0)**: Matrix structure pivot (e.g., concern/action_type changes), TF removal, persona change.

Edit `boss.md` first line:
```yaml
version: v1.1 (2026-04-28, added TF-3d image search)
```

Commit:
```
git commit -m "release: humanpowers project v1.1 - TF-3d added"
git tag v1.1
```
```

- [ ] **Step 3: Verify + commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "feat(finishing): boss final acceptance + boss.md version bump"
```

---

### Task 8: Modify subagent-driven-development (Light)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/subagent-driven-development/SKILL.md`

Per spec: TF lead pattern guidance.

- [ ] **Step 1: Add TF lead pattern section**

Append at end (or insert after agent dispatch section):

```markdown
## humanpowers TF Lead Pattern

In humanpowers, subagents play the role of TF Lead — ad-hoc per TF, no fixed domain identity.

**Dispatch convention**:
- Pass `TF-id` as primary context
- Subagent reads: `tfs.md#TF-{id}`, `tfs/{id}/expected-outputs.md`, `tfs/{id}/build-plan.md`
- Subagent acts within scope of that TF only
- Same human/agent can lead different TFs (no role attachment)

**Memory**:
- Per-TF scratchpad at `library/scratchpads/TF-{id}.md` (≤30 lines, auto-truncated by hook)
- NOT in `~/.claude/projects/.../memory/` (that's claude-code's per-project memory)
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/subagent-driven-development/SKILL.md
git commit -m "feat(subagent-driven): document TF lead pattern + scratchpad convention"
```

---

### Task 9: Modify dispatching-parallel-agents (Light)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/dispatching-parallel-agents/SKILL.md`

Per spec: TF-aware dispatch using depends_on graph.

- [ ] **Step 1: Add TF-aware dispatch section**

Append:

```markdown
## humanpowers TF-aware Parallel Dispatch

When dispatching parallel agents in humanpowers context:

1. Read `tfs.md`. Build dependency graph from `depends_on`.
2. Find frontier — TFs whose `depends_on` is all `status: verified`.
3. Dispatch one subagent per frontier TF (parallel) — pass `TF-id` and ensure context fork.
4. Wait for all to complete (each returns updated tfs.md status).
5. Re-compute frontier. Repeat until all TFs verified.

**Anti-pattern**: dispatching by domain (e.g., "FE agent"). humanpowers has no domain teams. Always dispatch by TF.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/dispatching-parallel-agents/SKILL.md
git commit -m "feat(dispatching-parallel): TF-aware dispatch using depends_on graph"
```

---

### Task 10: Rename using-superpowers → using-humanpowers (already copied; finalize content)

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/using-humanpowers/SKILL.md`

Task 2 already copied dir + bulk-rebranded text. Now finalize identity.

- [ ] **Step 1: Verify rename happened**

```bash
ls /Users/jay/code/user/humanpowers/skills/ | grep humanpowers
```

Expected: `using-humanpowers` (not `using-superpowers`).

- [ ] **Step 2: Update frontmatter description**

Read SKILL.md frontmatter. Update `name:` to `using-humanpowers`. Update `description:` to:

```yaml
description: Use when starting any conversation in a humanpowers project — establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
```

- [ ] **Step 3: Add identity note**

Insert after frontmatter, before existing content:

```markdown
## humanpowers identity

This is a fork of superpowers' `using-superpowers` skill, rebranded for humanpowers (boss-articulation enforcement). Behavior is similar but skills load humanpowers-namespace, not superpowers.

When in doubt, prefer **humanpowers** skills inside humanpowers projects (workspace at `~/humanpowers/{project}/`). Outside humanpowers projects, original superpowers may still be available.
```

- [ ] **Step 4: Verify + commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/using-humanpowers/
git commit -m "feat(using-humanpowers): finalize rename + identity note"
```

---

### Task 11: Create quiz skill (NEW, largest)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/quiz/SKILL.md`

Per spec section 7. D1 mandatory + D2 optional. 4 axes critique. cascade refinement.

- [ ] **Step 1: Create skill dir + SKILL.md frontmatter**

```bash
mkdir -p /Users/jay/code/user/humanpowers/skills/quiz
```

Create `/Users/jay/code/user/humanpowers/skills/quiz/SKILL.md`:

```markdown
---
name: quiz
description: Use after humanpowers:brainstorming when TF specs exist but expected-outputs aren't signed off. Forces boss to articulate expected behavior per TF via mandatory D1 quiz (agent asks, boss answers, agent critiques) and optional D2 self-response (boss writes own answers, agent compares, discrepancies trigger discussion + cascade refinement). Output = signed_off expected-outputs.md per TF, used directly as test spec by TDD/SDD downstream.
---

# Quiz Module

## Position in workflow

```
brainstorming (TF specs drafted)
  ↓
QUIZ (this skill)
  ├─ D1 mandatory: Agent → Boss
  └─ D2 optional: Boss → Agent
  ↓
writing-plans (TF-unit build plans)
  ↓
test-driven-development (uses expected-outputs.md as test spec)
  ↓
executing-plans (build)
  ↓
verification-before-completion (boss demo signoff)
```

## Inputs

- Workspace at `~/humanpowers/{project-name}/`
- `tfs.md` exists with at least 1 TF spec
- For each TF (specified arg or default to all `status: brainstorm-done`):
  - `tfs/{TF-id}/quiz.md` — agent generates if missing
  - `tfs/{TF-id}/response-d1-boss.md` — boss writes (mandatory)
  - `tfs/{TF-id}/response-d2-boss.md` — boss optionally provides
  - `tfs/{TF-id}/response-d2-agent.md` — agent writes (D2 only)
  - `tfs/{TF-id}/discussion.md` — agent appends discrepancies
  - `tfs/{TF-id}/expected-outputs.md` — final signed_off output

## D1 Mandatory — Agent → Boss

### Step 1: Generate quiz.md per TF

Read `tfs.md#TF-{id}` for 5 fields + `action_type`.

Generate quiz.md from `references/templates/quiz-template.md` baseline. Add 5-10 questions per TF, distributed across 4 axes:

- **Vagueness**: at least 1 Q targeting any vague term in WHAT/VERIFY
- **Consistency**: at least 1 Q tying to NFR or boss invariants
- **Completeness**: at least 1 Q on error/edge cases (e.g., "What if input is empty? What if N=0?")
- **Specificity**: at least 1 Q forcing concrete value (e.g., "What is 'fast'? Quantify in ms.")

Use action_type-specific question templates (see references/examples/quiz-{type}-example.md).

DO NOT pre-fill agent's own answers. Boss must articulate from blank.

### Step 2: Boss writes response-d1-boss.md

Use `references/templates/response-d1-template.md` as starting skeleton. Boss fills each Q answer.

humanpowers waits for boss to commit (or save) the file before proceeding.

Show boss the path:
```
Edit ~/humanpowers/{project}/tfs/{TF-id}/response-d1-boss.md
Save when done.
```

Use AskUserQuestion to wait:
```
Q: Have you completed response-d1-boss.md for TF-{id}? options: Done / Skip TF / Abort
```

### Step 3: Per-Q critique loop (AUQ ONE question at a time)

Read response-d1-boss.md for TF.

For each question (Q1, Q2, ...):

```
critiques = []
for axis in [Vagueness, Consistency, Completeness, Specificity]:
    issues = check_axis(boss_answer, axis, references/templates/critique-axes.md)
    critiques.extend(issues)

while critiques:
    critique = critiques.pop(0)  # ONE at a time
    new_answer = AskUserQuestion(
        question=critique.question_text,
        options=critique.options if critique.has_options else None,
        # else: free text
    )
    update_response_md(boss_answer, Q, new_answer)
    # re-evaluate THIS Q only
    critiques = [c for c in re_check(...)] 
    
# Q locked when no more critiques
mark Q as locked in response-d1-boss.md
```

**ANTI-PATTERN (banned)**: Bulk dump multiple critiques in one message ending "What do you think?" This is irresponsible delegation.

**REQUIRED**: One AUQ call per critique. Loop until agent has zero critiques for a Q.

### Step 4: All Qs locked → write expected-outputs.md

Aggregate all locked Q answers into `tfs/{TF-id}/expected-outputs.md`. Auto-derive test spec block per Q (see template).

Set `tfs.md#TF-{id}` `status: quiz-done` (Phase 1 marker).

## D2 Optional — Boss → Agent

After D1 complete (per TF), offer D2:

### Step A: Offer D2

```
AskUserQuestion:
  Q: D2 응답지 작성하시겠어요? (Boss provides own answers, agent compares)
  options:
    - Yes, write my own response sheet (specify filename)
    - Pass (skip D2)
```

If "Yes":

```
AskUserQuestion:
  Q: 템플릿 받으시겠어요? 또는 자유 형식?
  options:
    - 템플릿 (response-d2-template.md copied)
    - 자유 형식 (boss handles)
  + free text: filename for response-d2-boss.md (default = standard path)
```

### Step B-1: Agent maps freeform to Qs

After boss provides response-d2-boss.md:

Read it. Attempt to map content to quiz.md Q1, Q2, ... 

```
AskUserQuestion:
  Q: 보스 응답 매핑 결과: Q1=... / Q2=(미응답) / Q3=... 맞나요?
  options:
    - 맞음
    - 수정 (free text: provide corrections)
```

Loop until mapping confirmed.

### Step C: Agent writes response-d2-agent.md

For EACH Q in quiz, agent writes its own answer (independent of boss D1 + boss D2). Save to `tfs/{TF-id}/response-d2-agent.md`.

### Step D: Discrepancy detection

For each Q, compare boss D2 answer (if provided) vs agent answer.

If different (semantic, not just wording):
- Append to `tfs/{TF-id}/discussion.md` per `references/templates/discussion-template.md`:

```markdown
## Q{N} 불일치

**Boss D2 answer**: ...
**Agent answer**: ...
**Difference**: 
**Agent reasoning**: ...
**Decision**: pending
```

### Step E: Per-Q decision via AUQ

For each unresolved discrepancy:

```
AskUserQuestion:
  Q: Q{N} 불일치 — 어떻게 처리?
  options:
    - 1. 논의 필요
    - 2. Agent 답 채택 (보스 답 변경)
    - 3. Boss 답 유지 (agent 답 archive)
```

### Step F: 논의 필요 → discussion loop

If "1. 논의 필요":
- Re-read discussion.md + boss additional comments
- Agent responds with rebuttal/refinement
- Possibly multiple turns
- Final cascade decision (checkbox in discussion.md):
  - [ ] 해당 TF expected-outputs 갱신
  - [ ] 해당 TF 5필드 spec (tfs.md) 갱신
  - [ ] boss.md 불변식 / 페르소나 갱신
  - [ ] 다른 TF 영향 (flag only — boss 명시 invoke)

### Lock

All discrepancies resolved (option 1 final / 2 / 3) = D2 done. Update expected-outputs.md if cascade required.

Set `tfs.md#TF-{id}` `status: quiz-done`.

## Termination

After all selected TFs complete D1 (and optionally D2):

- All `tfs.md` rows have `status: quiz-done` for the selected TFs
- Update `.humanpowers/state.json` phase = `quiz-done`
- Next phase = `writing-plans`

Tell boss:
```
Quiz phase complete for {N} TFs. Next: humanpowers:writing-plans (TF-unit build plans).
Or: /humanpowers continue
```

## Boundaries

- **Don't** generate boss's answers in D1. Boss must write blank.
- **Don't** bulk-dump critiques. Per-Q AUQ only.
- **Don't** auto-cascade to (iv) other TFs. Flag only — boss explicitly invokes.
- **Don't** skip TFs with `status: brainstorm-done`. All must reach `quiz-done` before any builds.
```

- [ ] **Step 2: Verify SKILL.md valid + commit**

```bash
head -10 /Users/jay/code/user/humanpowers/skills/quiz/SKILL.md
cd /Users/jay/code/user/humanpowers
git add skills/quiz/
git commit -m "feat(quiz): NEW skill — D1 mandatory + D2 optional + 4 critique axes + cascade"
```

---

### Task 12: Create scaffold skill (NEW)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/scaffold/SKILL.md`

Per spec section 3.2: workspace tree generation.

- [ ] **Step 1: Create SKILL.md**

```bash
mkdir -p /Users/jay/code/user/humanpowers/skills/scaffold
```

Create `/Users/jay/code/user/humanpowers/skills/scaffold/SKILL.md`:

```markdown
---
name: scaffold
description: Use to create or initialize a humanpowers project workspace at ~/humanpowers/{project-name}/. Generates the full directory tree (boss.md / tfs.md / views/ / tfs/ / threads/ / library/ / .humanpowers/) with starter files. Invoked by dispatcher when no workspace detected during /humanpowers brainstorm.
---

# Scaffold Skill

## Inputs

- `project-name` (kebab-case or snake_case) — boss provides via AskUserQuestion if missing.

## Steps

### Step 1: Validate project-name

Use AskUserQuestion if not provided:
```
Q: 프로젝트 이름을 입력해주세요 (kebab-case 또는 snake_case).
   예: shopping-search-buy / data_pipeline_v2
```

Validate: lowercase, no spaces, no special chars except `-` or `_`.

### Step 2: Refuse if workspace exists

```bash
WS=~/humanpowers/{project-name}
if [ -d "$WS" ]; then
  echo "Workspace exists at $WS. Use /humanpowers continue or /humanpowers abort."
  exit 1
fi
```

### Step 3: Create directory tree

```bash
mkdir -p ~/humanpowers/{project-name}/{views,tfs,threads,library/scratchpads,.humanpowers}
```

### Step 4: Initialize boss.md

Create `~/humanpowers/{project-name}/boss.md`:

```markdown
---
project: {project-name}
version: v0.1
created: {ISO-date}
---

# {project-name} — Boss Charter

## Goal

(filled by brainstorming)

## Persona (Target user)

(filled by brainstorming)

## 핵심 불변식 (Boss Invariants — Layer 0 NFR)

### 보안
(filled during brainstorming)

### 데이터 무결성

### 결정성

### 컴플라이언스

## Notes

(boss-only edits below this line)
```

### Step 5: Initialize tfs.md

Create `~/humanpowers/{project-name}/tfs.md`:

```markdown
# TF Registry — {project-name}

> SSOT for TF definitions. Do NOT edit views/ — they are auto-rendered from this file.

## Schema

```yaml
- id: TF-{N}{letter}
  name: short name
  concern: boss-level scenario
  action_type: ui | api | data | infra | cross-cutting
  who: persona
  what: behavior/result
  why: value hypothesis
  verify_form: gherkin | curl | sql | checklist | composite
  nfr_local: []
  depends_on: []
  status: brainstorm-done | quiz-done | designed | built | verified
  mode: independent | facilitating | collaboration
```

## TFs

(append by brainstorming)
```

### Step 6: Initialize state.json

Create `~/humanpowers/{project-name}/.humanpowers/state.json`:

```json
{
  "project": "{project-name}",
  "phase": "brainstorm",
  "version": "v0.1",
  "created": "{ISO-date}",
  "tfs_total": 0,
  "tfs_brainstormed": 0,
  "tfs_quiz_done": 0,
  "tfs_built": 0,
  "tfs_verified": 0
}
```

### Step 7: Initialize empty views

Create empty `~/humanpowers/{project-name}/views/{macro,spec,progress}.md`:

```markdown
> Auto-rendered from tfs.md. Do NOT edit. Run scripts/render-views.sh after tfs.md changes.

(empty — no TFs yet)
```

### Step 8: Initialize library/INDEX.md

Create `~/humanpowers/{project-name}/library/INDEX.md`:

```markdown
# Library — {project-name}

Reference index for cross-TF resources, runbooks, and scratchpads.

## Scratchpads (per TF lead, ≤30 lines, auto-truncated)

- (none yet)

## Runbooks

- (none yet)

## External references

- (none yet)
```

### Step 9: Confirm + initial commit

```bash
cd ~/humanpowers/{project-name}
git init 2>/dev/null || true  # optional — boss can decide
ls -la
```

### Step 10: Hand off to brainstorming

```
✓ Workspace created at ~/humanpowers/{project-name}/
Next: humanpowers:brainstorming
Or: /humanpowers continue
```

## Boundaries

- Don't fill boss.md / tfs.md content — that's brainstorming's job
- Don't init git inside `~/humanpowers/{project}` automatically (boss decides)
- Don't symlink to plugin code dir
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/scaffold/
git commit -m "feat(scaffold): NEW skill — initialize humanpowers workspace tree"
```

---

### Task 13: Create operate skill (NEW)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/operate/SKILL.md`

Per spec: TF lead invocation router.

- [ ] **Step 1: Create SKILL.md**

```bash
mkdir -p /Users/jay/code/user/humanpowers/skills/operate
```

Create `/Users/jay/code/user/humanpowers/skills/operate/SKILL.md`:

```markdown
---
name: operate
description: Use to invoke a TF Lead role and execute work for a specific TF. Routes from /humanpowers operate {TF-id}. Loads TF context (spec + expected-outputs + build-plan + scratchpad), assumes the lead persona for that TF, executes pending work, updates status. Generic — no domain identity. Same agent can lead different TFs.
---

# Operate Skill

## Inputs

- `TF-id` (e.g., `TF-1a`) — required
- Workspace at `~/humanpowers/{project}/` (current project from .humanpowers/state.json)

## Steps

### Step 1: Validate TF exists

```bash
WS=~/humanpowers/$(jq -r .project ~/humanpowers/*/.humanpowers/state.json | head -1)
grep -q "id: $TF_ID" $WS/tfs.md || { echo "TF $TF_ID not found"; exit 1; }
```

### Step 2: Load TF context

Read in this order:
1. `tfs.md` — extract just `TF-{id}` 5-field row
2. `tfs/{TF-id}/expected-outputs.md` — signed_off VERIFY
3. `tfs/{TF-id}/build-plan.md` — current build plan (if exists)
4. `library/scratchpads/{TF-id}.md` — accumulated notes (if exists)
5. `boss.md` — invariants only (Layer 0)
6. Any `threads/*.md` post tagged with `{TF-id}` — recent decisions

DO NOT load: other TFs' specs, other TFs' build-plans (out of scope).

### Step 3: Assume TF Lead persona

```
You are TF Lead for {TF-id} ({TF-name}).
Scope: ONLY this TF. Other TFs = out of scope unless thread-tagged.
Action type: {action_type}
Identity: ad-hoc (no domain). Same agent may lead different TFs in different sessions.
Invariants (Layer 0 from boss.md): [list]
Local NFR (Layer 1 from tfs.md): [list]
Expected outputs (signed_off): [summary from expected-outputs.md]
```

### Step 4: Determine work mode

Check `tfs.md#TF-{id}` status:

| status | Action |
|--------|--------|
| brainstorm-done | invoke humanpowers:quiz (not operate) — abort |
| quiz-done | invoke humanpowers:writing-plans for this TF — produce build-plan.md |
| designed | execute build-plan.md tasks (this is operate's main flow) |
| built | invoke humanpowers:verification-before-completion |
| verified | nothing to do — abort |

### Step 5: Execute build-plan tasks (status=designed)

Read `tfs/{TF-id}/build-plan.md`. Find first unchecked task.

Execute task using TDD:
- Write failing test
- Verify failure
- Implement minimal code
- Verify pass
- Commit (small commit per task)
- Mark `[x]` in build-plan.md

If task references unclear behavior → re-check expected-outputs.md. If still unclear → halt + thread post.

After all build-plan tasks complete: set tfs.md status = `built`. Hand off to verification.

### Step 6: Update scratchpad (≤30 lines)

After session, write/update `library/scratchpads/{TF-id}.md`:

```markdown
# TF-{id} Scratchpad — Lead notes

## Session 2026-04-28
- Completed Tasks 3, 4
- Blocker: depends_on TF-2b (status: designed) — wait
- Next session: continue from Task 5

(keep under 30 lines — auto-truncated by hook)
```

### Step 7: Boundaries

- **Don't** modify boss.md (Layer 0 invariants)
- **Don't** modify other TFs' files
- **Don't** invoke quiz module from operate (separate phase)
- **Don't** auto-promote NFR — flag only, agent must thread post for boss confirm

### Step 8: Terminal state

After session ends:
- All build-plan tasks done → invoke humanpowers:verification-before-completion
- Some tasks done → update scratchpad, hand back to dispatcher (`/humanpowers continue`)
- Blocked → write `threads/blocker-{TF-id}.md`, hand back

Tell boss next step explicitly.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/operate/
git commit -m "feat(operate): NEW skill — generic TF Lead invocation, no domain identity"
```

---

### Task 14: Create review skill (NEW)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/review/SKILL.md`

Per spec: boss verification + version bump trigger.

- [ ] **Step 1: Create SKILL.md**

```bash
mkdir -p /Users/jay/code/user/humanpowers/skills/review
```

Create `/Users/jay/code/user/humanpowers/skills/review/SKILL.md`:

```markdown
---
name: review
description: Use after multiple TFs are verified to perform boss review of the project state, optionally bump boss.md version, and identify next priorities. Distinct from per-TF verification (which is humanpowers:verification-before-completion). This is project-level review with cascade decisions.
---

# Review Skill

## When to invoke

- After at least 2 TFs reach `status: verified`
- Or boss explicitly requests `/humanpowers review`
- Before finishing-a-development-branch (final wrap)

## Steps

### Step 1: Aggregate state

Run `scripts/render-views.sh` to ensure views/*.md current.

Read:
- `views/progress.md` — status overview
- `boss.md` — invariants + version
- All `threads/*.md` — open vs resolved

### Step 2: Show boss the review summary

Display:
```
Project: {name}
Version: {boss.md version}

TFs: {N total}
  brainstorm-done: {x}
  quiz-done: {x}
  designed: {x}
  built: {x}
  verified: {x}

Open threads: {count}
Resolved threads: {count}

Boss invariant violations (auto-detect): {none | list}
```

Pull invariant violations by scanning recent commits + tfs.md changes.

### Step 3: AUQ — review options

```
Q: 프로젝트 review 결과. 다음 액션?
options:
  - 1. 다음 TF 우선순위 결정 (continue building)
  - 2. boss.md version bump (minor/major)
  - 3. Cascade — 특정 TF expected-outputs 재검토 (re-quiz)
  - 4. Open threads 처리 (boss reviews threads)
  - 5. Finalize (humanpowers:finishing-a-development-branch)
```

### Step 4a: Option 1 — Priority decision

Compute `depends_on` frontier — TFs whose deps are verified.

AUQ:
```
Q: 다음 TF 후보 (frontier): TF-X / TF-Y / TF-Z. 어디 우선?
options: [TF-X, TF-Y, TF-Z, parallel-all, custom]
```

Hand off: `/humanpowers operate {chosen-TF}`.

### Step 4b: Option 2 — Version bump

AUQ:
```
Q: 버전 bump 종류?
options:
  - minor (X.Y → X.Y+1) — TF 추가 / 비-구조 edit
  - major (X.Y → X+1.0) — 매트릭스 구조 pivot / TF 제거
```

Edit boss.md frontmatter version. Commit + tag git.

### Step 4c: Option 3 — Cascade re-quiz

AUQ:
```
Q: 어느 TF 의 expected-outputs 재검토?
free text: TF-id
```

Reset that TF's `status: brainstorm-done`. Hand off to humanpowers:quiz.

### Step 4d: Option 4 — Threads

List open threads. AUQ per thread:
```
Q: thread {topic} 상태?
options: [resolved (close), still open, escalate]
```

### Step 4e: Option 5 — Finalize

Hand off to humanpowers:finishing-a-development-branch.

### Step 5: Update state.json

Set `last_review` timestamp. Persist any chosen next phase.

## Boundaries

- Don't auto-bump version — boss must choose
- Don't auto-close threads — boss must mark
- Don't cascade re-quiz on multiple TFs at once — one at a time
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/review/
git commit -m "feat(review): NEW skill — project-level review + cascade decisions + version bump"
```

---

### Task 15: Modify writing-skills (Light) + finalize as-is rebrand

**Files:**
- Modify: `/Users/jay/code/user/humanpowers/skills/writing-skills/SKILL.md`

- [ ] **Step 1: Add humanpowers identity note**

Insert after frontmatter:

```markdown
## humanpowers identity

When creating new skills FOR humanpowers projects, follow these conventions:

1. Skill name lowercase, no `humanpowers-` prefix needed (plugin namespace handled by manifest)
2. Description should reference humanpowers context if applicable (e.g., "Use after humanpowers:brainstorming when...")
3. For TF-related skills, take `TF-id` as primary input
4. Always reference workspace path `~/humanpowers/{project}/...`
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/writing-skills/
git commit -m "feat(writing-skills): humanpowers identity guidance for new skills"
```

---

### Task 16: Templates (5 files)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/references/templates/quiz-template.md`
- Create: `/Users/jay/code/user/humanpowers/references/templates/response-d1-template.md`
- Create: `/Users/jay/code/user/humanpowers/references/templates/response-d2-template.md`
- Create: `/Users/jay/code/user/humanpowers/references/templates/discussion-template.md`
- Create: `/Users/jay/code/user/humanpowers/references/templates/critique-axes.md`

- [ ] **Step 1: Create dir**

```bash
mkdir -p /Users/jay/code/user/humanpowers/references/templates
```

- [ ] **Step 2: Create quiz-template.md**

Create `/Users/jay/code/user/humanpowers/references/templates/quiz-template.md`:

```markdown
# {TF-id} {TF-name} — Expected Outputs Quiz

> Status: draft | reviewing | signed_off
> action_type: ui | api | data | infra | cross-cutting
> Generated: {date}
> Linked TF spec: tfs.md#TF-{id}

## Q1: {question 1-line summary}

{question body — what must be decided}

**Boss answer**:
<!-- 자유 기술. 한 줄도 OK. 빈 칸도 OK (agent 가 한 번 더 물어봄). -->


**Critique log**:
<!-- agent fills. round-by-round axis + what was caught -->


**Test spec (auto-derived)**:
<!-- after lock, agent fills. boss answer → executable test -->


---

## Q2: ...

(Add more questions per quiz module's per-axis distribution rule)
```

- [ ] **Step 3: Create response-d1-template.md**

Create `/Users/jay/code/user/humanpowers/references/templates/response-d1-template.md`:

```markdown
# {TF-id} — Boss Response (D1, mandatory)

> Linked quiz: quiz.md
> action_type: ...

## Q1: 

(Free-form answer here. Don't worry about format. Agent will follow up on vague/missing parts.)


## Q2: 

...
```

- [ ] **Step 4: Create response-d2-template.md**

Create `/Users/jay/code/user/humanpowers/references/templates/response-d2-template.md`:

```markdown
# {TF-id} — Boss Self-Response (D2 optional)

> Free format OK. One Q only OK. Paste from existing notes/spec OK.
> Agent will map your content to quiz Q numbers, fill in agent's own answers, and discuss discrepancies.

(Boss writes here. No format required — agent reads markdown.)
```

- [ ] **Step 5: Create discussion-template.md**

Create `/Users/jay/code/user/humanpowers/references/templates/discussion-template.md`:

```markdown
## Q{N} 불일치

**Boss answer**: ...

**Agent answer**: ...

**Difference**:
- Field: ...
- Boss: ...
- Agent: ...

**Agent reasoning**: ...

**Decision**: 1. 논의 필요 | 2. Agent 답 채택 | 3. Boss 답 유지

---

## 논의 (Decision = 1)

**Boss 추가 의견**: ...

**Agent 응답**: ...

**Cascade 영향 범위**:
- [ ] 해당 TF expected-outputs 갱신
- [ ] 해당 TF 5필드 spec (tfs.md) 갱신
- [ ] boss.md 불변식 / 페르소나 갱신
- [ ] 다른 TF 영향 (flag only — 보스 명시 invoke 필요)

**Final**:
```

- [ ] **Step 6: Create critique-axes.md**

Create `/Users/jay/code/user/humanpowers/references/templates/critique-axes.md`:

```markdown
# Critique 4 Axes (Agent Internal Checklist)

Use this when reading boss's quiz answer. Check each axis. ANY hit = additional critique.

## Axis 1 — Vagueness (모호)

- 정량 부족 ("빠르다" / "5개")
- 주체 불명 ("사용자" — 누구?)
- 처리 방식 불명 ("에러" — 어떤 에러? 어떤 처리?)
- 경계 불명 ("많다" / "적다")

## Axis 2 — Consistency (일관성)

- TF spec NFR (Layer 1) 와 모순
- 다른 TF 답안 (다른 expected-outputs.md) 와 모순
- boss.md 불변식 (Layer 0) 위반

## Axis 3 — Completeness (완결성)

- Happy path 만? Error / edge / 0 / overflow / 동시성 / 권한 X 처리?
- Input variant (한글 / 영문 / 특수문자 / Emoji / 빈값)?
- Timeout / 네트워크 실패?
- Race condition / 동시 입력?

## Axis 4 — Specificity (구체성)

- 정의 부재 ("인기순" — 인기 정의?)
- Timezone / window 부재 ("30일" — KST? Rolling?)
- 동작 모호 ("더보기" — append vs 교체?)
- "권장" — 강제? 옵션? 둘 다?

## Termination rule

Critique ends when ALL 4 axes return 0 issues for the current Q.

## Anti-pattern

NEVER bulk-dump all axes' issues in one AUQ message ending "Thoughts?". One AUQ call per critique.
```

- [ ] **Step 7: Verify + commit**

```bash
ls /Users/jay/code/user/humanpowers/references/templates/
cd /Users/jay/code/user/humanpowers
git add references/templates/
git commit -m "feat(templates): 5 quiz/response/discussion/critique templates"
```

---

### Task 17: Examples (6 files + README, generic domain)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/references/examples/README.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/quiz-ui-example.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/quiz-api-example.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/quiz-data-example.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/quiz-infra-example.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/quiz-crosscut-example.md`
- Create: `/Users/jay/code/user/humanpowers/references/examples/d2-discussion-example.md`

Domain choice: GENERIC abstract examples (not real domain like 홈쇼핑). Boss learns the pattern.

- [ ] **Step 1: Create dir**

```bash
mkdir -p /Users/jay/code/user/humanpowers/references/examples
```

- [ ] **Step 2: Create README.md**

Create `/Users/jay/code/user/humanpowers/references/examples/README.md`:

```markdown
# Examples — humanpowers Quiz

Generic abstract examples. Use these to understand the pattern, then apply to your project's domain.

## Files

| File | Purpose |
|------|---------|
| `quiz-ui-example.md` | UI TF quiz, signed_off — Gherkin VERIFY |
| `quiz-api-example.md` | API TF quiz, signed_off — cURL VERIFY |
| `quiz-data-example.md` | Data TF quiz, signed_off — SQL assertion |
| `quiz-infra-example.md` | Infra TF quiz, signed_off — checklist + curl |
| `quiz-crosscut-example.md` | Cross-cutting TF, signed_off — composite VERIFY |
| `d2-discussion-example.md` | D2 boss vs agent discrepancy → discussion → cascade |

## How to use

When agent generates a new quiz.md, it consults the appropriate example for question patterns. Boss answering should consult to see what "good" looks like.

These are NOT prescriptive — your domain may need different question shapes. Adapt.
```

- [ ] **Step 3: Create quiz-ui-example.md (generic)**

Create `/Users/jay/code/user/humanpowers/references/examples/quiz-ui-example.md`:

```markdown
# TF-{X} Generic UI Form — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: ui
> Boss articulation: 5 questions / 18 turns
> Linked TF spec: tfs.md#TF-{X}

## Q1: Form submission behavior

When user fills form fields F1, F2, F3 and clicks Submit, what exactly happens?
(Validation order / error display / success indicator / redirect / data persistence)

**Boss answer (final, locked after 3 rounds)**:
- Validation order: F1 → F2 → F3 (top to bottom). Stop at first invalid.
- Error display: red border on invalid field + tooltip below "Field {name}: {reason}"
- F1 valid = required + length 1-50
- F2 valid = email format (RFC 5322 simplified)
- F3 valid = numeric + range 18-100
- All valid → POST /submit, button shows spinner
- 200 response → green checkmark + "Saved" toast 3s + redirect to /list
- 4xx response → red banner with response.message
- 5xx response → red banner "서버 오류, 잠시 후 다시 시도"
- Timeout 10s → red banner "응답 지연, 다시 시도"

**Critique log**:
- Round 1 [Vagueness]: "valid" → criteria? / "spinner" → which? / "redirect" → where?
- Round 2 [Specificity]: F2 email format / F3 range / toast duration
- Round 3 [Completeness]: 4xx vs 5xx vs timeout error handling

**Test spec (auto-derived)**:
- E2E: fill F1="" → submit → expect F1 red border + tooltip "Field F1: required"
- E2E: fill F1="A", F2="invalid" → submit → expect F2 red border
- E2E: fill all valid → submit → expect spinner → 200 → toast "Saved" → /list
- E2E: server returns 503 → expect red banner with default text
- E2E: server delays > 10s → expect timeout banner

## Q2: Field state persistence

If user fills form, navigates away (back button), returns — should fields persist?

**Boss answer**:
- Persist in browser sessionStorage on every keystroke
- Restore on page load if sessionStorage has entry < 1 hour old
- Clear sessionStorage on successful submit
- Clear button = explicit clear all + clear storage

**Critique log**:
- Round 1 [Specificity]: "persist" → where? localStorage vs sessionStorage / "navigate away" → all routes or just back button?
- Round 2 [Completeness]: TTL on storage / explicit clear

**Test spec**:
- Unit: typing → sessionStorage updated within 100ms
- E2E: fill → back → forward → expect fields restored
- E2E: fill → submit success → back → expect fields empty

## Q3: Accessibility (a11y)

What a11y standards must form meet?

**Boss answer**:
- WCAG AA contrast (4.5:1)
- All inputs have <label> associated
- Error messages = aria-live="polite"
- Tab order = visual order
- Submit button = aria-disabled when validating

## Q4: Mobile/responsive

Layout below viewport 600px wide?

**Boss answer**:
- Single column stack
- Inputs full-width minus 16px padding
- Submit button = full-width
- Error tooltips = inline below field (not absolute positioned — would cut off)

## Q5: Loading states

Initial form load (data fetched async)?

**Boss answer**:
- Skeleton placeholder for form fields (3 grey rectangles)
- Disabled submit until data loaded
- Loading > 5s = "Loading..." text + spinner
- Load failure = error banner "Form load failed, refresh to retry"
```

- [ ] **Step 4: Create quiz-api-example.md**

Create `/Users/jay/code/user/humanpowers/references/examples/quiz-api-example.md`:

```markdown
# TF-{X} Generic POST API — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: api
> Boss articulation: 6 questions / 22 turns

## Q1: Request shape

POST /api/resource — accepted body shape?

**Boss answer**:
```json
{
  "name": "string, 1-100 chars, required",
  "type": "enum: type_a | type_b | type_c, required",
  "metadata": {
    "key": "string, optional",
    "tags": ["string array, max 10 items, each 1-50 chars"]
  }
}
```

Content-Type: application/json. Other = 415.

**Critique log**: Vagueness ("string"→length?), Specificity (type→enum values?), Completeness (Content-Type rejection?)

## Q2: Response shape — success

201 Created body?

**Boss answer**:
```json
{
  "id": "uuid v4",
  "created_at": "ISO 8601 UTC",
  "name": "echoed",
  "type": "echoed",
  "metadata": "echoed or null"
}
```

Header: `Location: /api/resource/{id}`.

## Q3: Response shape — error

4xx body shape?

**Boss answer**:
```json
{
  "error": {
    "code": "string (e.g., VALIDATION_FAILED, NOT_FOUND)",
    "message": "human-readable",
    "field": "name of failed field, or null"
  }
}
```

400 = validation, 401 = auth, 403 = permission, 404 = not found, 409 = conflict, 422 = unprocessable.

## Q4: Auth

Required?

**Boss answer**:
- Bearer token in Authorization header
- Token = JWT signed with HS256
- Token expiry 1 hour
- Missing/invalid token = 401 with `error.code = AUTH_REQUIRED` or `AUTH_INVALID`

## Q5: Rate limit

**Boss answer**:
- 100 req/min per user
- 429 response with `Retry-After: {seconds}` header
- Body = standard error shape with `code: RATE_LIMITED`

## Q6: Idempotency

Same request, retry-safe?

**Boss answer**:
- Optional `Idempotency-Key` header (UUID)
- Same key + same body within 24h = return original response
- Same key + different body = 409 conflict

**Test spec**:
- cURL with valid body → 201, body shape matches
- cURL missing required field → 400, error.field = name
- cURL invalid Content-Type → 415
- cURL no auth → 401
- cURL same idempotency key + body → same response (cached)
- cURL same key + different body → 409
- 101 rapid requests → 429 with Retry-After
```

- [ ] **Step 5: Create quiz-data-example.md**

Create `/Users/jay/code/user/humanpowers/references/examples/quiz-data-example.md`:

```markdown
# TF-{X} Generic Aggregation — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: data

## Q1: Aggregation behavior

Daily aggregation job: input = events table, output = daily_metrics. What exactly?

**Boss answer**:
- Input: `events(timestamp UTC, user_id, event_type, value DECIMAL)`
- Output: `daily_metrics(date DATE, event_type, count INT, sum_value DECIMAL, distinct_users INT)`
- Partitioning: input by HOUR (24 partitions/day), aggregate scans only previous day's partitions
- Output upsert: ON CONFLICT (date, event_type) DO UPDATE
- Run schedule: daily at 02:00 UTC for previous 24h

**SQL assertion (auto-derived)**:
```sql
-- After job for 2026-04-27, expect:
SELECT count(*) FROM daily_metrics WHERE date = '2026-04-27';
-- Expected: count > 0 AND count = (SELECT count(DISTINCT event_type) FROM events WHERE date_trunc('day', timestamp) = '2026-04-27')

SELECT sum(count) FROM daily_metrics WHERE date = '2026-04-27';
-- Expected: equal to (SELECT count(*) FROM events WHERE date_trunc('day', timestamp) = '2026-04-27')

SELECT sum_value FROM daily_metrics WHERE date = '2026-04-27' AND event_type = 'X';
-- Expected: equal to (SELECT sum(value) FROM events WHERE event_type = 'X' AND ...)
```

## Q2: Late arrivals

Events with timestamp = 2026-04-27 arriving after job ran?

**Boss answer**:
- Re-run job with `--reprocess-date 2026-04-27` flag (manual trigger)
- Auto-detect window: 7 days lookback nightly job re-aggregates
- Late arrivals after 7d = ignored, logged to `late_events_orphan` table

## Q3: Idempotency

Re-run for same date — overwrites or appends?

**Boss answer**:
- Overwrite (UPSERT). Source of truth = always latest run.
- Audit log captures every run with run_id + duration + rows_processed.

## Q4: Failure handling

Job fails midway?

**Boss answer**:
- Transaction rollback (no partial daily_metrics rows for that date)
- Re-trigger via runbook (scripts/rerun-aggregation.sh)
- Alert sent if not retried within 4 hours
```

- [ ] **Step 6: Create quiz-infra-example.md**

Create `/Users/jay/code/user/humanpowers/references/examples/quiz-infra-example.md`:

```markdown
# TF-{X} Generic Service Deployment — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: infra

## Q1: Deployment readiness

Service "X" deployable to staging when?

**Boss answer (checklist)**:
- [x] Docker image built + tagged with git SHA
- [x] Image pushed to registry (ECR / GCR / DockerHub)
- [x] Helm chart values rendered for staging env
- [x] Health endpoint `/healthz` returns 200 within 30s of pod start
- [x] Readiness endpoint `/ready` returns 200 once all dependencies confirmed
- [x] Migration: `python manage.py migrate --check` passes (no pending unapplied)
- [x] Required env vars set in k8s secret (DATABASE_URL, REDIS_URL, API_KEY)
- [x] Logging level INFO, output JSON-formatted to stdout
- [x] Metrics endpoint `/metrics` exposes Prometheus-compatible

## Q2: Health check details

`/healthz` and `/ready` semantics?

**Boss answer**:
- `/healthz`: process alive. Returns 200 + `{"status": "ok"}` always (unless deadlocked).
- `/ready`: dependency check. Returns 200 only if DB ping + Redis ping succeed within 1s. Otherwise 503 + `{"status": "unready", "failed": ["db" | "redis"]}`.
- k8s liveness probe = `/healthz` every 10s, fail 3 in row = restart.
- k8s readiness probe = `/ready` every 5s, fail 2 in row = remove from service.

## Q3: Rollback

Bad deploy?

**Boss answer**:
- `helm rollback {release} {prev-revision}` — atomic
- Rollback within 5 min of deploy = automatic if `/ready` < 50% in 3 min window
- Beyond 5 min = manual decision (data migration may have run, rollback risky)

## Q4: Secrets

How handled?

**Boss answer**:
- k8s sealed-secrets (or AWS Secrets Manager / Vault)
- Never in env vars in plain helm values
- Rotation: 90 days, runbook documented
```

- [ ] **Step 7: Create quiz-crosscut-example.md**

Create `/Users/jay/code/user/humanpowers/references/examples/quiz-crosscut-example.md`:

```markdown
# TF-{X} Generic Determinism — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: cross-cutting

## Q1: Determinism scope

Which paths must be deterministic (same input → same output)?

**Boss answer**:
- All LLM calls in workflow X = temperature 0 + top_p 1
- All DB queries with sort = explicit ORDER BY (no implicit ordering)
- All UUID generation in tests = seeded random (e.g., uuid5 with namespace)
- Floating point aggregation = use `decimal.Decimal` for $ amounts (not float)

## Q2: Composite VERIFY

How does this TF "pass"?

**Boss answer**:
- TF-CC = composite — passes when:
  - TF-1a + TF-1b + TF-2a + TF-2b all run their VERIFY 3x in sequence
  - All 3 runs produce identical results (byte-equal for JSON, row-equal for SQL output)
- Failure mode: 1 of 3 runs differs → TF-CC fail → impacted TFs revert to `built` (not `verified`)

## Q3: Exceptions allowed

Where determinism MAY relax?

**Boss answer**:
- Logging: timestamps OK to differ (don't compare in VERIFY)
- Trace IDs: random per request OK (don't compare)
- Cache: if cache miss vs hit changes timing but not value, OK

## Q4: Detection mechanism

How catch non-determinism?

**Boss answer**:
- CI runs each impacted TF VERIFY 3x with same seed
- diff outputs (excluding timestamp/trace_id fields)
- Any non-empty diff = build fails
```

- [ ] **Step 8: Create d2-discussion-example.md**

Create `/Users/jay/code/user/humanpowers/references/examples/d2-discussion-example.md`:

```markdown
# TF-{X} D2 Discussion — Cascade Refinement (EXAMPLE)

> Linked: response-d2-boss.md / response-d2-agent.md

## Q5: Search index infrastructure

**Boss D2 answer**:
- Postgres tsvector + GIN index
- 한글 형태소 분석기 = mecab-ko

**Agent answer**:
- ElasticSearch separate cluster
- 한글 = nori analyzer

**Difference**:
- Field: search infrastructure
- Boss: Postgres tsvector (single DB)
- Agent: ES separate cluster

**Agent reasoning**: "검색 latency / 확장성. 1만 SKU+ 시 Postgres FTS 가 GIN 인덱스로도 부하 큼."

**Decision**: 1. 논의 필요

---

## 논의

**Boss 추가 의견**:
- ES = overkill at current scale.
- Concurrent users ≤ 100 / SKU count ≤ 1000.
- Operational cost (cluster management, monitoring) too high for current value.
- Postgres tsvector benchmark on 10k rows showed <50ms p99 → sufficient.

**Agent 응답**:
- 동의. 현 규모에서 Postgres tsvector 충분.
- 단, 향후 SKU 1만 도달 시 재검토 trigger 필요 (boss invariant 추가 권장).

**Cascade 영향 범위**:
- [x] 해당 TF expected-outputs 갱신 — Q5 lock with "Postgres tsvector + GIN, mecab-ko"
- [x] 해당 TF 5필드 spec (tfs.md) 갱신 — `nfr_local: ["검색 latency p99 < 50ms"]`
- [x] boss.md 불변식 / 페르소나 갱신 — Add invariant: "검색 인프라 = Postgres-only. SKU > 10000 도달 시 재설계 trigger."
- [ ] 다른 TF 영향 (flag only — 보스 명시 invoke 필요)
  - Flagged: TF-2 상품 상세 (검색 결과 click) might share index — needs explicit re-quiz

**Final**: Postgres tsvector + GIN index + mecab-ko. Locked. boss.md version → v1.1.
```

- [ ] **Step 9: Verify + commit**

```bash
ls /Users/jay/code/user/humanpowers/references/examples/
cd /Users/jay/code/user/humanpowers
git add references/examples/
git commit -m "feat(examples): 6 quiz examples (UI/API/Data/Infra/Crosscut/D2-discussion) + README"
```

---

### Task 18: Dispatcher skill (single entry point)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/skills/humanpowers/SKILL.md`

Per spec section 9: single entry, state-routed via `.humanpowers/state.json`. mega-optimize pattern.

- [ ] **Step 1: Create dispatcher SKILL.md**

```bash
mkdir -p /Users/jay/code/user/humanpowers/skills/humanpowers
```

Create `/Users/jay/code/user/humanpowers/skills/humanpowers/SKILL.md`:

```markdown
---
name: humanpowers
description: Single entry point for humanpowers projects. Auto-detects current phase from .humanpowers/state.json and routes to brainstorming / quiz / writing-plans / executing-plans / verification / review / finishing. Boss types `/humanpowers` and dispatcher figures out next step. Use this when boss says "I want to start" or "continue" or just types /humanpowers.
---

# humanpowers Dispatcher

## Behavior

Single entry to humanpowers workflow. Detects state, dispatches to appropriate skill.

## State detection

```bash
# Check if cwd is inside ~/humanpowers/{project}/
WS=""
if [[ "$(pwd)" == "$HOME/humanpowers/"* ]]; then
  WS=$(echo "$(pwd)" | sed -E "s|($HOME/humanpowers/[^/]+).*|\1|")
fi

# Or check if state.json exists in any cd-able subdir
if [ -z "$WS" ] && [ -f ./.humanpowers/state.json ]; then
  WS="$(pwd)"
fi
```

If no workspace → invoke humanpowers:scaffold (Step 1 below).

If workspace exists → read `state.json` field `phase` and dispatch (Step 2).

## Step 1: No workspace → scaffold

Output to Claude:
```
No humanpowers workspace detected.
Invoking humanpowers:scaffold to initialize a new project.
```

Hand off to humanpowers:scaffold.

## Step 2: Workspace exists → state echo + dispatch

Read `.humanpowers/state.json`:

```bash
PHASE=$(jq -r .phase ~/humanpowers/{project}/.humanpowers/state.json)
TFS_TOTAL=$(jq -r .tfs_total ...)
TFS_QUIZ_DONE=$(jq -r .tfs_quiz_done ...)
TFS_BUILT=$(jq -r .tfs_built ...)
TFS_VERIFIED=$(jq -r .tfs_verified ...)
```

Output state echo:
```
Currently in: ~/humanpowers/{project}/
Phase: {PHASE}
TFs: {VERIFIED}/{TOTAL} verified, {BUILT}/{TOTAL} built, {QUIZ_DONE}/{TOTAL} quiz-done
```

## Step 3: Phase routing

| phase | Next skill |
|-------|-----------|
| `brainstorm` | humanpowers:brainstorming |
| `brainstorm-done` | humanpowers:quiz |
| `quiz-done` | humanpowers:writing-plans |
| `designed` | humanpowers:executing-plans (or operate per TF) |
| `built` | humanpowers:verification-before-completion |
| `verified` (some) | humanpowers:review or continue per TF |
| `verified` (all) | humanpowers:finishing-a-development-branch |

If user passed explicit phase arg (`/humanpowers quiz` etc.), override auto-routing.

## Step 4: Boss override commands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase |
| `/humanpowers jump {phase}` | force jump to phase (warn if skipping) |
| `/humanpowers operate {TF-id}` | invoke humanpowers:operate with TF-id |
| `/humanpowers review` | invoke humanpowers:review |
| `/humanpowers abort` | mark workspace as aborted in state.json + STOP |

## Step 5: Always state-echo before action

Before invoking next skill, show:
```
Currently: {phase}
Next: humanpowers:{skill}
Or override: /humanpowers continue | jump {phase} | operate {TF} | review | abort
```

Boss may interrupt to use override.

## Boundaries

- Don't auto-progress past phase boundaries without boss involvement.
- Don't skip quiz when going from brainstorm-done to writing-plans.
- Don't claim verified without verification skill.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add skills/humanpowers/
git commit -m "feat(humanpowers): NEW dispatcher skill — single entry, state-routed"
```

---

### Task 19: Scripts (state + render + truncate)

**Files:**
- Create: `/Users/jay/code/user/humanpowers/scripts/check-state.sh`
- Create: `/Users/jay/code/user/humanpowers/scripts/update-state.sh`
- Create: `/Users/jay/code/user/humanpowers/scripts/render-views.sh`
- Create: `/Users/jay/code/user/humanpowers/scripts/shelf-truncate.sh`

- [ ] **Step 1: Create dir**

```bash
mkdir -p /Users/jay/code/user/humanpowers/scripts
```

- [ ] **Step 2: Create check-state.sh**

Create `/Users/jay/code/user/humanpowers/scripts/check-state.sh`:

```bash
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
```

```bash
chmod +x /Users/jay/code/user/humanpowers/scripts/check-state.sh
```

- [ ] **Step 3: Create update-state.sh**

Create `/Users/jay/code/user/humanpowers/scripts/update-state.sh`:

```bash
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
```

```bash
chmod +x /Users/jay/code/user/humanpowers/scripts/update-state.sh
```

- [ ] **Step 4: Create render-views.sh**

Create `/Users/jay/code/user/humanpowers/scripts/render-views.sh`:

```bash
#!/usr/bin/env bash
# Usage: scripts/render-views.sh [workspace-path]
# Reads tfs.md → renders views/{macro,spec,progress}.md

set -euo pipefail

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
```

```bash
chmod +x /Users/jay/code/user/humanpowers/scripts/render-views.sh
```

- [ ] **Step 5: Create shelf-truncate.sh (hook executor)**

Create `/Users/jay/code/user/humanpowers/scripts/shelf-truncate.sh`:

```bash
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
```

```bash
chmod +x /Users/jay/code/user/humanpowers/scripts/shelf-truncate.sh
```

- [ ] **Step 6: Verify + commit**

```bash
ls -la /Users/jay/code/user/humanpowers/scripts/
cd /Users/jay/code/user/humanpowers
git add scripts/
git commit -m "feat(scripts): state check/update + view rendering + shelf truncate"
```

---

### Task 20: Hooks config

**Files:**
- Create: `/Users/jay/code/user/humanpowers/hooks/hooks.json`

- [ ] **Step 1: Create hooks dir**

```bash
mkdir -p /Users/jay/code/user/humanpowers/hooks
```

- [ ] **Step 2: Create hooks.json**

Create `/Users/jay/code/user/humanpowers/hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/shelf-truncate.sh"
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/shelf-truncate.sh"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 3: Verify hook JSON valid**

```bash
cat /Users/jay/code/user/humanpowers/hooks/hooks.json | python3 -m json.tool
```

- [ ] **Step 4: Commit**

```bash
cd /Users/jay/code/user/humanpowers
git add hooks/
git commit -m "feat(hooks): PostToolUse Edit/Write → shelf truncate to ≤30 lines"
```

---

### Task 21: Self-test E2E (Step 12)

**Files:**
- Create: `~/humanpowers/_self-test/` (test workspace, not committed to humanpowers repo)

This is a manual validation step. Goal: prove plugin works end-to-end on a generic test project.

- [ ] **Step 1: Install plugin locally**

```bash
# Symlink humanpowers to claude plugins dir (or use plugin marketplace install if registered)
mkdir -p ~/.claude/plugins/humanpowers
ln -sf /Users/jay/code/user/humanpowers/* ~/.claude/plugins/humanpowers/ 2>/dev/null || \
  cp -r /Users/jay/code/user/humanpowers/. ~/.claude/plugins/humanpowers/

# Or use claude code plugin add command if available
# claude code plugin add /Users/jay/code/user/humanpowers/
```

Verify install:
```bash
ls ~/.claude/plugins/humanpowers/skills/ | head -5
```

- [ ] **Step 2: Open new claude code session, navigate to test workspace**

```bash
mkdir -p ~/humanpowers
cd ~/humanpowers
claude
```

Inside claude session, type: `/humanpowers`

Expected: humanpowers dispatcher detects no workspace, invokes scaffold, asks for project name.

Provide: `selftest-generic`

Expected: workspace at `~/humanpowers/selftest-generic/` created with full tree.

- [ ] **Step 3: Run brainstorming**

Type: `/humanpowers continue` (or `/humanpowers brainstorming`)

Expected: 비서 persona engages. Asks scope-narrowing questions.

Provide minimal generic project: e.g., "TODO list app, single user, web only".

Expected: agent pushes back on vague answers, refines, eventually produces:
- boss.md with charter + invariants
- 2-3 TFs in tfs.md (e.g., TF-1a TODO UI, TF-1b TODO API, TF-1c TODO data)

- [ ] **Step 4: Run quiz**

Type: `/humanpowers continue` → routes to humanpowers:quiz.

Expected: For each TF, agent generates quiz.md → boss writes response-d1-boss.md → agent critiques per Q via AUQ → expected-outputs.md signed_off.

Manual abort acceptable for self-test — record observations:
- Did 비서 persona refuse vague answers?
- Did AUQ go one-Q-at-a-time?
- Did expected-outputs.md form correctly?

- [ ] **Step 5: Run writing-plans**

Type: `/humanpowers continue`. 

Expected: humanpowers:writing-plans → produces `tfs/{TF-id}/build-plan.md` per TF.

Inspect a build-plan.md — TDD format, bite-sized tasks, file paths.

- [ ] **Step 6: Skip executing-plans for self-test**

For Phase 1 self-test, do NOT actually build. Mark this as future work.

Manually edit one TF's status to `verified` in tfs.md to test downstream phases.

```bash
# Manually set TF-1a status: verified in ~/humanpowers/selftest-generic/tfs.md
```

- [ ] **Step 7: Run verification**

Type: `/humanpowers continue` (after manually setting status).

Expected: humanpowers:verification-before-completion engages. Boss demo signoff prompt appears.

Manually accept (PASS) for self-test.

- [ ] **Step 8: Run review**

Type: `/humanpowers review`.

Expected: review skill aggregates state, shows summary, offers options 1-5.

- [ ] **Step 9: Run finishing**

Type: `/humanpowers continue` (when all TFs verified).

Expected: humanpowers:finishing-a-development-branch engages. Asks final acceptance.

- [ ] **Step 10: Render views**

```bash
cd ~/humanpowers/selftest-generic
/Users/jay/code/user/humanpowers/scripts/render-views.sh
ls views/
cat views/macro.md
```

Expected: 3 view files, properly formatted matrices.

- [ ] **Step 11: Verify shelf truncate hook**

```bash
# Create a scratchpad with > 30 lines
for i in $(seq 1 50); do echo "line $i" >> ~/humanpowers/selftest-generic/library/scratchpads/test.md; done

# Trigger an edit (simulate via plugin context — easiest = manually invoke hook script)
echo '{"tool_input": {"file_path": "'$HOME'/humanpowers/selftest-generic/library/scratchpads/test.md"}}' | /Users/jay/code/user/humanpowers/scripts/shelf-truncate.sh

wc -l ~/humanpowers/selftest-generic/library/scratchpads/test.md
```

Expected: 30 lines (truncated from 50).

- [ ] **Step 12: Document E2E test results**

Create `/Users/jay/code/user/humanpowers/docs/E2E-self-test-2026-04-28.md`:

```markdown
# Phase 1 E2E Self-Test — 2026-04-28

## Pass/Fail per skill

| Skill | Pass? | Notes |
|-------|-------|-------|
| dispatcher | | |
| scaffold | | |
| brainstorming | | |
| quiz | | |
| writing-plans | | |
| verification-before-completion | | |
| review | | |
| finishing-a-development-branch | | |
| render-views.sh | | |
| shelf-truncate.sh | | |

## Issues found
(list any bugs or unexpected behavior)

## Phase 1 Gate
- [ ] PASS — all skills work, ready for use
- [ ] PARTIAL — some skills need fixes; see issues
- [ ] FAIL — major rework needed
```

- [ ] **Step 13: Final commit (Phase 1 complete)**

```bash
cd /Users/jay/code/user/humanpowers
git add docs/E2E-self-test-2026-04-28.md
git commit -m "test: Phase 1 E2E self-test results"
git tag v0.1.0
```

---

## Self-Review

### 1. Spec coverage check

| Spec section | Tasks |
|--------------|-------|
| §3.2 14 fork skills + 4 new | Task 2 (bulk copy) + Task 3-10, 15 (modifies) + Task 11-14 (new) |
| §3.3 LICENSE attribution | Task 1 |
| §4 Workspace model | Task 12 (scaffold) |
| §5 TF data model | Task 3 (brainstorming) + Task 12 (scaffold tfs.md schema) |
| §6 Matrix views | Task 19 (render-views.sh) |
| §7 Quiz module | Task 11 |
| §8 Templates + Examples | Task 16 + Task 17 |
| §9 Plugin UX (single endpoint) | Task 18 (dispatcher) |
| §11 Open issues — shelf truncate | Task 19 + 20 |
| §12 Phase 1 Step 1-12 | Task 1 (Step 1), Task 2 (Step 2), Task 3-5 (Step 3 = Heavy), Task 6-7 (Step 4 = Medium), Task 8-9 (Step 5 = Light), Task 10 (Step 6), Task 11-14 (Step 7), Task 16-17 (Step 8), Task 18 (Step 9), Task 19 (Step 10), Task 20 (Step 11), Task 21 (Step 12) |

→ All Phase 1 spec items covered. Spec patch (writing-skills) handled in Pre-task.

### 2. Placeholder scan

- "TBD" / "TODO" / "fill in details" in plan — none found in step bodies
- "Add appropriate error handling" — none
- "Similar to Task N" — none (each task self-contained)
- All code/content blocks present

### 3. Type/name consistency

- `TF-id` format consistent: `TF-{N}{letter}` (e.g., TF-1a)
- File names consistent: `tfs.md`, `quiz.md`, `response-d1-boss.md`, `response-d2-boss.md`, `response-d2-agent.md`, `discussion.md`, `expected-outputs.md`, `build-plan.md`
- Phase names consistent: `brainstorm` / `brainstorm-done` / `quiz-done` / `designed` / `built` / `verified`
- action_type values consistent: `ui` / `api` / `data` / `infra` / `cross-cutting`
- Path consistency: plugin code = `/Users/jay/code/user/humanpowers/`, project workspace = `~/humanpowers/{project}/`

### 4. Critical risks

- **Skill chaining** (R2 finding): Task 3 brainstorming has "invoke humanpowers:quiz" — undocumented but expected to work. If fails: add fallback "boss runs /humanpowers continue manually."
- **Hook reliability** (Task 20): Shelf truncate hook may not fire on all editors. Add fallback to scaffold step: "Boss runs scripts/shelf-truncate.sh manually if needed."
- **render-views.sh Python deps**: requires PyYAML. Add to Task 19 Step 4: `python3 -c "import yaml" || pip install pyyaml`.

### Fixes inline

(no fixes applied — issues noted for executor awareness, low-risk)

---

## Plan complete

Plan saved to `/Users/jay/code/user/humanpowers/docs/plans/2026-04-28-humanpowers-phase1.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** — Dispatch fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?

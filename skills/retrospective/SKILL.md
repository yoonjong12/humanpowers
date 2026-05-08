---
name: retrospective
description: Use after humanpowers:finishing-a-development-branch completes (phase=finished). Two phases — 적재 (load learnings from project artifacts into ~/.humanpowers/learnings/{skill}.md) and 정리 (consolidate learnings, prune stale, deduplicate). Evolves the framework per-user over time.
---

# Retrospective

## Overview

The retrospective extracts what the framework learned from a completed project and writes it into persistent learnings documents. Other skills read these documents as an additional input source in future projects — the framework improves over time.

**Announce at start:** "I'm using the retrospective skill to extract and consolidate learnings from this project."

**Two phases:**
- **Phase 1 — 적재 (load)**: Analyze completed project artifacts → classify learnings → write to `~/.humanpowers/learnings/{skill}.md`
- **Phase 2 — 정리 (consolidate)**: Scan all learnings → deduplicate → prune stale → developer decides

Phase 1 runs after every project. Phase 2 is optional — offer it, developer decides.

## Preconditions

```bash
DIR="$(pwd)"; WS=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
  DIR="$(dirname "$DIR")"
done
```

Check `state.json`:
- `phase` must be `finished`. If not: "Project not finished. Run `humanpowers:finishing-a-development-branch` first." **STOP.**

## Learnings location

All learnings live at `~/.humanpowers/learnings/{skill}.md`.

- User-owned, not plugin-owned. Retrospective writes here; individual skills read from here.
- If `~/.humanpowers/learnings/` does not exist, create it.
- If a skill's learnings file does not exist, copy the default from the plugin: `<plugin>/references/learnings/{skill}.md` → `~/.humanpowers/learnings/{skill}.md`.

## Learnings document format

Each learnings file is a markdown guideline document with real case examples. Not flat bullets. Not YAML.

Structure per entry:

```markdown
### <short guideline title>

**Guideline:** <one-sentence principle>

**Case:** <real example from a project — what happened, what decision was made, what the outcome was>

**When to apply:** <trigger condition — when this guideline is relevant>
```

Entries accumulate over projects. Each entry traces to a real case — no abstract advice without evidence.

## Phase 1 — 적재 (load)

### Step 1: Read project artifacts

Read in order:
1. `<WS>/.humanpowers/problem.md` — problem definition, invariants
2. `<WS>/.humanpowers/tasks.md` — all tasks, statuses, item IDs
3. For each task `{id}`:
   - `tasks/{id}/round1.md` — quiz matrix (perception gap surface)
   - `tasks/{id}/round2.md` — if exists (discrepancies)
   - `tasks/{id}/discussion.md` — if exists (resolved disagreements)
   - `tasks/{id}/plan.md` — execution plan
   - `tasks/{id}/verify.md` — verification outcome

### Step 2: Identify perception gap residuals

The quiz surfaces the perception gap between developer and agent. The retrospective asks: **where did the gap persist despite the quiz?**

Sources of residual gap:
- Round 2 discrepancies that required discussion (gap survived round 1)
- Verification debrief issues (gap survived quiz + operate)
- Developer corrections during operate (plan deviated from intent)
- Loop kick-backs (quiz → brainstorming/writing-plans — something was missing)

For each residual, note:
- Which skill phase it surfaced in (quiz / operate / verify)
- Which dimension was involved (Intent / Observable / Constraint / etc.)
- What the gap was (agent assumption vs developer intent)
- How it was resolved

### Step 3: Classify learnings by skill

Map each learning to the skill where it would have prevented the issue:

| Target skill | Learning type |
|-------------|---------------|
| quiz | Dimension activation patterns, question framing that worked/failed, evidence anchors that caught issues |
| operate | TDD patterns, plan execution pitfalls, scope boundary violations |
| verification-before-completion | Demo patterns that caught issues, debrief questions that surfaced hidden problems |
| brainstorming | Problem decomposition patterns, invariant formulations that held/broke |
| writing-plans | Task granularity lessons, dependency ordering, action_type classification |
| review | Cross-task cascade patterns, flag-vs-fix decisions |

A learning may map to multiple skills. Write to each.

### Step 4: Draft entries

For each learning, draft an entry in the guideline format (see format above). The case must reference the actual project — what task, what happened, what the resolution was.

Present all drafted entries to the developer grouped by target skill:

```
Retrospective found {N} learnings from this project:

quiz ({n} entries):
  - <title 1>: <one-line summary>
  - <title 2>: <one-line summary>

operate ({n} entries):
  - <title 1>: <one-line summary>

[etc.]

Review and approve? Options: Approve all / Review one-by-one / Edit specific / Skip
```

### Step 5: Write on approval

For each approved entry:
1. Check if `~/.humanpowers/learnings/{skill}.md` exists. If not, copy default from `<plugin>/references/learnings/{skill}.md`.
2. Append the new entry at the end of the file.

After writing:
```
적재 complete. {N} learnings written to {M} skill files.
```

## Phase 2 — 정리 (consolidate)

Offer after Phase 1 completes:

```
Phase 1 done. Phase 2 — 정리 (consolidate learnings)?

This scans all ~/.humanpowers/learnings/*.md for duplicates and stale entries.
Run now or later?
```

If developer declines, stop. If accepted:

### Step A: Scan all learnings files

```bash
ls ~/.humanpowers/learnings/*.md
```

For each file, read and parse all entries.

### Step B: Detect issues

Two categories:

**Duplicates:** Two entries across files (or within the same file) that express the same guideline. Criteria: same trigger condition + same principle, even if different case examples.

**Stale:** An entry whose guideline contradicts a newer entry, or whose trigger condition no longer applies (e.g., references a pattern the developer has since abandoned).

### Step C: Present to developer

For each issue found:

```
Issue {n}/{total}:

Type: Duplicate / Stale
File(s): ~/.humanpowers/learnings/{skill}.md
Entry: <title>

[For duplicate]: Similar to <other entry title> in {other file}. Merge or keep both?
[For stale]: Contradicts <newer entry> / references deprecated pattern. Remove or keep?
```

One issue at a time. Developer decides each.

### Step D: Execute decisions

- **Merge**: Combine two entries — keep the stronger case example, unify the guideline.
- **Remove**: Delete the entry from the file.
- **Keep**: No action.

After all issues resolved:
```
정리 complete. {merged} merged, {removed} removed, {kept} kept unchanged.
```

## Boundaries

- **Don't** auto-write learnings without developer approval (Step 4 gate).
- **Don't** modify plugin source files. Learnings live at `~/.humanpowers/learnings/`, not in the plugin directory.
- **Don't** invent abstract advice. Every entry must trace to a real case from the project.
- **Don't** auto-invoke Phase 2. Offer it. Developer decides.
- **Don't** delete entries in Phase 2 without developer confirmation per entry.
- **Don't** write learnings about project-specific decisions (those go in the ADR). Write learnings about **process patterns** — how the framework itself could have worked better.

## Integration

**Called by:**
- **finishing-a-development-branch** — offers retrospective handoff after project completion

**Reads:**
- All workspace artifacts (problem.md, tasks.md, per-task round1/round2/discussion/plan/verify)

**Writes:**
- `~/.humanpowers/learnings/{skill}.md` — one file per skill

**Does NOT call:**
- Any other humanpowers skill. Retrospective is terminal.

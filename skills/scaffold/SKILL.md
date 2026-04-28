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

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

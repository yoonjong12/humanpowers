---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## ADR digest at finish

humanpowers workspaces are local-only. At finish time, this skill drafts an ADR summarizing design decisions — but where it lives is the developer's call.

### Step 1: Confirm all tasks verified

Read `<workspace>/.humanpowers/state.json`. Confirm `tasks_verified == tasks_total`. If not, error: "Not all tasks verified. Cannot write ADR." and stop.

### Step 2: Ask the developer for a slug

Ask one question: "What's the slug for this feature?" — short kebab-case identifier (e.g., `pcr-curator-review-injection`). The slug becomes the ADR filename.

### Step 3: Read source artifacts

Read in order:
- `<workspace>/.humanpowers/problem.md` (for problem summary, project invariants)
- `<workspace>/.humanpowers/tasks.md` (for task list, action_types, depends_on)
- For each task `{id}`: `<workspace>/.humanpowers/tasks/{id}/round1.md`, `round2.md` if present, `plan.md`, `verify.md`

### Step 4: Draft ADR

Compose the ADR body (do NOT write to disk yet):

```markdown
# <feature title from problem.md "What" section>

## Status

Accepted

## Problem

<one-paragraph summary derived from problem.md "What" + "Why">

## Project invariants

<bulleted list copied from problem.md "Project invariants" section>

## Decisions

<for each task, one or two sentences summarizing the key decisions made. Reference the file paths the task touched. Format:>

### Task <id>: <task name>

<key decisions from quiz round 1 + round 2 if present, plus any plan-level choices>. Touches: `<paths>`.

## Alternatives considered

<bullets surfaced during brainstorming or quiz round 2 — explicit alternatives the developer rejected>

## Consequences

<what changed in the repo, what is now possible, what new constraints exist>

## Verify outcomes

<for each task, one line: what was verified and how — test pass, demo signoff, etc.>
```

### Step 5: Present ADR and ask where to put it

Show the draft to the developer, then ask:

```
ADR draft ready. Where should it live?

1. Commit to repo (docs/decisions/<slug>.md)
2. Keep in workspace only (<workspace>/library/adr-<slug>.md) — not committed
3. Skip ADR entirely
```

**Do NOT assume.** Different projects have different conventions. If the repo has no existing `docs/decisions/` directory, that's a signal — ask, don't create.

### Step 6: Write and optionally commit

- **Option 1**: Write to `<target_repo>/docs/decisions/<slug>.md`, create dir if needed, `git add && git commit -m "design: <feature title>"`.
- **Option 2**: Write to `<workspace>/library/adr-<slug>.md`. No git commit.
- **Option 3**: Do nothing.

### Step 6: Optionally bump version + release

If the project uses semver and the developer wants a release, prompt for `major / minor / patch` and run the project's release flow (out of scope for humanpowers; the developer's existing release process applies).

### Step 7: Update workspace phase

```bash
bash scripts/update-state.sh "$WS" phase finished
```

The workspace remains local. The developer can delete `.humanpowers/` at this point if they don't need to resume; the ADR is the durable record.

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR

**Step A — Push:**
```bash
git push -u origin <feature-branch>
```

**Step B — Draft PR body:**

Use the project's PR template. Look for (in order):
1. `<workspace>/library/prs/TEMPLATE.md` (humanpowers workspace template)
2. `.github/PULL_REQUEST_TEMPLATE.md` or `.bitbucket/PULL_REQUEST_TEMPLATE.md`
3. Previous PRs in the repo as reference (`git log --merges --oneline -5`)

Draft the PR body following the template. Present draft to developer:
```
Here's the PR draft. Review and let me know if you want changes:

Title: <title>
Target: <base-branch>

<body following template>
```

**Step C — Developer confirms:**

Wait for explicit confirmation before creating the PR. Developer may:
- Approve as-is → create PR
- Request edits → revise and re-present
- Abort → keep branch pushed, skip PR

**Step D — Create PR (after confirmation only):**
```bash
# Bitbucket
# Provide URL: https://bitbucket.org/<org>/<repo>/pull-requests/new?source=<branch>&t=1

# GitHub
gh pr create --title "<title>" --body "<confirmed body>"
```

Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 5)

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | ✓ |
| 2. Create PR | - | ✓ | ✓ | - |
| 3. Keep as-is | - | - | ✓ | - |
| 4. Discard | - | - | - | ✓ (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) — after all tasks complete
- **operate --batch** — after the final task in the batch is verified

**Pairs with:**
- **using-git-worktrees** — cleans up the worktree created by that skill

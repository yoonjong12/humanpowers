# humanpowers E2E Self-Test

Manual end-to-end validation. Run after every breaking change to the dispatcher, brainstorming, or workspace schema. Two top-level scenarios (greenfield + in-repo) plus error-path and Subcommand verification.

## How to run

Open a fresh Claude Code session in each test directory and follow the steps. Record the observed result and PASS/FAIL in the corresponding section. Commit the filled-in form when done.

---

## Scenario 1: Greenfield (cwd outside any git repo)

**Setup:**

```bash
rm -rf /tmp/hp-greenfield
mkdir /tmp/hp-greenfield && cd /tmp/hp-greenfield
# Open Claude Code session here
```

**Steps:**

1. Type `/humanpowers`
2. Expected: dispatcher creates `.humanpowers/` in `/tmp/hp-greenfield/`. Output mentions workspace_kind = `external`, target_repo = `null`.
3. Verify state.json:
   ```bash
   cat .humanpowers/state.json
   ```
   Expected: `phase: ""`, `target_repo: null`, `workspace_kind: "external"`, all tfs counts = 0.
4. Dispatcher hands off to brainstorming.
5. Engage brainstorming through to sign-off. Expected: `.humanpowers/problem.md` produced.
6. Phase transitions to `problem-defined`. Verify:
   ```bash
   bash <plugin-dir>/scripts/check-state.sh /tmp/hp-greenfield
   ```
   Expected: `phase: problem-defined`.
7. Type `/humanpowers continue`. Expected: invokes humanpowers:quiz.

| Step | PASS/FAIL | Observed |
|------|-----------|----------|
| 1 — dispatcher invokes |  |  |
| 2 — workspace created with external kind |  |  |
| 3 — state.json schema correct |  |  |
| 4 — handoff to brainstorming |  |  |
| 5 — problem.md written |  |  |
| 6 — phase transition to problem-defined |  |  |
| 7 — continue → quiz |  |  |

---

## Scenario 2: In-repo (cwd inside a fresh git repo)

**Setup:**

```bash
rm -rf /tmp/hp-inrepo
mkdir /tmp/hp-inrepo && cd /tmp/hp-inrepo && git init
# Open Claude Code session here
```

**Steps:**

1. Type `/humanpowers`
2. Expected: dispatcher creates `.humanpowers/` at the repo root. Output mentions workspace_kind = `in-repo`, target_repo = `/tmp/hp-inrepo`.
3. Verify state.json:
   ```bash
   cat .humanpowers/state.json
   ```
   Expected: `phase: ""`, `target_repo: "/tmp/hp-inrepo"`, `workspace_kind: "in-repo"`.
4. Dispatcher hands off to brainstorming.
5. Engage brainstorming, sign off, verify problem.md and phase transition.
6. Verify .gitignore behavior: state.json should be gitignored (only `problem.md`, `tfs.md`, etc. show up in `git status`). Run `git status` and confirm.

| Step | PASS/FAIL | Observed |
|------|-----------|----------|
| 1 — dispatcher invokes |  |  |
| 2 — workspace created with in-repo kind |  |  |
| 3 — state.json schema correct |  |  |
| 4 — handoff to brainstorming |  |  |
| 5 — problem.md + phase transition |  |  |
| 6 — gitignore excludes state.json + shelves |  |  |

---

## Scenario 3: Old-workspace error path

**Setup:**

```bash
rm -rf /tmp/hp-old
mkdir -p /tmp/hp-old/.humanpowers
echo '{"phase":"brainstorm","project":"old"}' > /tmp/hp-old/.humanpowers/state.json
cd /tmp/hp-old
# Open Claude Code session here
```

**Steps:**

1. Type `/humanpowers`
2. Expected: dispatcher (or check-state.sh propagation) errors with: "v0.1.x workspace detected. Delete `.humanpowers/` and re-init with `/humanpowers`."
3. Confirm no skill is invoked, no further work proceeds.

| Step | PASS/FAIL | Observed |
|------|-----------|----------|
| 1 — error fires |  |  |
| 2 — message matches expected |  |  |
| 3 — no skill invoked |  |  |

---

## Scenario 4: Subcommand verification

In one of the test workspaces (Scenario 1 or 2 after at least one TF exists):

| Subcommand | Expected | PASS/FAIL | Observed |
|------------|----------|-----------|----------|
| `/humanpowers continue` | resumes current phase |  |  |
| `/humanpowers jump quiz` | jumps phase, warns if skipping a gate |  |  |
| `/humanpowers operate TF-1` | invokes operate for TF-1 |  |  |
| `/humanpowers review` | invokes review skill |  |  |
| `/humanpowers abort` | sets phase = aborted, stops |  |  |

---

## Per-skill behavior verification

Each of the 18 skills must respond as expected when invoked in its phase.

| Skill | Expected | PASS/FAIL | Notes |
|-------|----------|-----------|-------|
| humanpowers (dispatcher) | context detect + skeleton create + route |  |  |
| brainstorming | one-Q-at-a-time elicit + problem.md |  |  |
| quiz | D1 mandatory + D2 optional + 4 critique axes |  |  |
| writing-plans | per-TF plan.md with action_type/depends_on |  |  |
| operate | per-TF TDD build, target_repo via state.json |  |  |
| verification-before-completion | per-TF demo signoff |  |  |
| review | cross-TF cascade decisions |  |  |
| finishing-a-development-branch | version bump + release |  |  |
| using-humanpowers | session-start orientation, points to dispatcher |  |  |
| systematic-debugging | invoked directly (not by dispatcher) for bugs |  |  |
| test-driven-development | red/green/refactor discipline |  |  |
| using-git-worktrees | per-feature worktree setup |  |  |
| executing-plans | batch alternative to operate |  |  |
| subagent-driven-development | task-by-task fresh subagent dispatch |  |  |
| dispatching-parallel-agents | parallel-eligible TFs |  |  |
| requesting-code-review | review template prep |  |  |
| receiving-code-review | review handling |  |  |
| writing-skills | skill creation discipline |  |  |

---

## Sign-off

Date filled: _______
Tested by: _______
Overall result: PASS / FAIL

If FAIL, list the failing scenarios at the top of this document and create follow-up issues.

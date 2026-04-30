# task-3 Profile Edit Form — Expected Behavior Quiz (EXAMPLE, locked)

> Status: locked
> action_type: ui
> Developer articulation: 6 cells / 14 turns
> Linked task spec: tasks.md#task-3

## Activation log

| Dimension | Active? | Reason | Predicted points |
|-----------|---------|--------|---------------------------|
| Intent | yes | "profile edit" boundary ambiguous (avatar? password? notifications?) | 1 |
| Observable | yes | form layout, error display, success state | 3 |
| Acceptance | yes | submit success criteria | 1 |
| Constraint | yes | a11y invariant from problem.md | 1 |
| Assumption | no | input schema fully specified in `task-3.assumption-1` | 0 |
| Dependency | yes | `PATCH /users/{id}` endpoint owned by task-1 | 1 |
| Edge | yes | empty / overlong / invalid character handling | 1 |
| Failure | yes | API 4xx / 5xx / timeout handling | 1 |
| Decision | no | no remaining branches once Edge + Failure are answered | 0 |

## Coverage matrix

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | Q-Intent.task-3.observable-1: which fields are editable in scope | – | – |
| Observable | Q-Obs.task-3.observable-1: form layout | Q-Obs.task-3.observable-2: error display style | Q-Obs.task-3.observable-3: success state |
| Acceptance | Q-Acc.task-3.verify-condition-1: submit success criterion | – | – |
| Constraint | Q-Cons.invariant-2: a11y compliance level | – | – |
| Dependency | Q-Dep.task-3.dependency-1: PATCH endpoint contract | – | – |
| Edge | Q-Edge.task-3.observable-1: empty / overlong input handling | – | – |
| Failure | Q-Fail.task-3.dependency-1: API error response handling | – | – |

## Q bodies

### Q-Intent.task-3.observable-1: which fields are editable in this task

**Cited item**: `task-3.observable-1` (`tasks.md`)

The task name says "Profile edit." The preliminary outline mentioned four fields. Confirming the scope so adjacent surfaces (avatar upload, password change, notification preferences) are explicitly in or out.

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Display name, email, bio only
- B. A + avatar image upload
- C. A + password change
- D. other (write own)

**Developer answer**: A
**Source**: `problem.md#out-of-scope-2` ("avatar upload deferred to v2"), `problem.md#out-of-scope-3` ("password change handled by separate /security route")
**Critique log**:
- Turn 3 — agent: "task name says 'profile' which often includes avatar; please confirm out-of-scope items in problem.md cover this."
- Turn 4 — developer: "yes, out-of-scope-2 and out-of-scope-3 cover those."

**Test spec (auto-derived)**:
- Form contains exactly: display name, email, bio inputs
- No avatar upload control
- No password fields

---

### Q-Obs.task-3.observable-2: error display style

**Cited item**: `task-3.observable-2` (`tasks.md`)

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. Inline tooltip below each invalid field, red border on the field
- B. Single banner at top of form listing all errors
- C. other (write own)

**Developer answer**: A
**Source**: `tasks.md#task-3.observable-2`, design discussion turn 8 (existing component library convention)
**Critique log**:
- Turn 9 — agent: "tooltip stays visible how long?" → "until field becomes valid or focus leaves"

**Test spec (auto-derived)**:
- Empty display name → red border + tooltip "Display name is required" below the input
- Tooltip dismisses when field becomes valid

---

### Q-Cons.invariant-2: a11y compliance level

**Cited item**: `invariant-2` (`problem.md` — "All UI must meet WCAG 2.1 AA")

**Expected answer shape**: yes/no (does this task introduce any AA-conformance work beyond using existing accessible components?)

**Developer answer**: no — the existing form components in the design system are AA-compliant; this task only composes them
**Source**: `problem.md#invariant-2`, library audit doc URL
**Critique log**: clean

**Test spec (auto-derived)**:
- Lighthouse a11y score ≥ 95 on the rendered form
- All inputs associated with labels

---

### Q-Edge.task-3.observable-1: empty / overlong input handling

**Cited item**: `task-3.observable-1`

**Expected answer shape**: free text (≤ 60 words)

**Developer answer**: empty display name → required error before submit. Display name > 50 chars → truncated visually with ellipsis but accepted up to 100; > 100 rejected with "max 100 characters" tooltip. Bio 0–500 chars allowed. Email blank → required; invalid format → "Enter a valid email address."
**Source**: `tasks.md#task-3.constraint-1` (50/100/500 limits) + design discussion turn 11
**Critique log**:
- Turn 12 — agent: "overlong = soft truncate visual or hard limit?" → developer added the soft 50 / hard 100 split

**Test spec (auto-derived)**:
- 0-char display name → submit blocked, tooltip shown
- 101-char display name → submit blocked
- 51-100 char display name → submit allowed
- Invalid email regex → submit blocked

---

### Q-Fail.task-3.dependency-1: API error response handling

**Cited item**: `task-3.dependency-1` (PATCH /users/{id} from task-1)

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Show inline tooltip on the field the server flagged (4xx with field-level errors)
- B. Show form-level red banner with the server's message
- C. Both A and B (field-level when available, banner fallback)
- D. other (write own)

**Developer answer**: C
**Source**: `tasks/task-1/round1.md#Q-Obs.task-1.observable-2` (locked: server returns `{errors: [{field, message}]}` for 4xx)
**Critique log**:
- Turn 13 — agent: "5xx and timeouts go to banner only?" → "yes, with retry hint"

**Test spec (auto-derived)**:
- Server 422 with `{errors: [{field: "email", message: "..."}]}` → tooltip on email field
- Server 503 → banner "Server error, please retry shortly"
- Network timeout > 10s → banner "Connection timed out"

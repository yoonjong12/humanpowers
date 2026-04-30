# task-1 PATCH /users/{id} — Expected Behavior Quiz (EXAMPLE, locked)

> Status: locked
> action_type: api
> Developer articulation: 7 cells / 16 turns
> Linked task spec: tasks.md#task-1

## Activation log

| Dimension | Active? | Reason | Predicted points |
|-----------|---------|--------|---------------------------|
| Intent | yes | scope of editable fields ↔ profile-edit task | 1 |
| Observable | yes | request shape, response shape, error envelope | 3 |
| Acceptance | yes | success criteria for happy path | 1 |
| Constraint | yes | latency invariant, auth scope | 2 |
| Assumption | yes | existing user record schema | 1 |
| Dependency | no | self-contained (no upstream service) | 0 |
| Edge | yes | unknown user id, no-op patch (no fields changed) | 2 |
| Failure | yes | validation error, conflict, server error | 1 |
| Decision | yes | partial vs full update semantics | 1 |

## Coverage matrix

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | Q-Intent.task-1.observable-1: which fields can PATCH change | – | – |
| Observable | Q-Obs.task-1.observable-1: request body shape | Q-Obs.task-1.observable-2: success response shape | Q-Obs.task-1.observable-3: error envelope shape |
| Acceptance | Q-Acc.task-1.verify-condition-1: success criterion | – | – |
| Constraint | Q-Cons.invariant-3: latency p99 budget | Q-Cons.task-1.constraint-1: auth scope required | – |
| Assumption | Q-Assume.task-1.assumption-1: existing user record fields | – | – |
| Edge | Q-Edge.task-1.observable-1: unknown user id | Q-Edge.task-1.observable-1: no-op patch | – |
| Failure | Q-Fail.task-1.observable-3: 4xx envelope content | – | – |
| Decision | Q-Dec.task-1.observable-1: partial vs full update | – | – |

## Q bodies

### Q-Obs.task-1.observable-1: request body shape

**Cited item**: `task-1.observable-1` (`tasks.md`)

**Expected answer shape**: free text (≤ 80 words; show JSON)

**Developer answer**:

```json
PATCH /users/{id}
{
  "display_name"?: "string",
  "email"?: "string",
  "bio"?: "string"
}
```

All fields optional. Any subset of the three keys. Unknown keys → 400 with `{errors: [{field, message: "unknown field"}]}`.

**Source**: `problem.md#criterion-2` (RESTful API convention), discussion turn 5
**Critique log**:
- Turn 6 — agent: "what about extra keys?" → developer added the 400 rule

**Test spec (auto-derived)**:
- `PATCH /users/123 {"display_name": "X"}` → 200
- `PATCH /users/123 {"foo": "bar"}` → 400 with errors[0].field == "foo"

---

### Q-Cons.invariant-3: latency p99 budget

**Cited item**: `invariant-3` (`problem.md` — "all write endpoints respond within 500ms p99")

**Expected answer shape**: write number (with unit)

**Developer answer**: 200ms p99 (well under invariant; this endpoint touches one row + writes one event)
**Source**: `problem.md#invariant-3`, discussion turn 9 (DB benchmark on existing schema)

**Test spec (auto-derived)**:
- Load test: 100 RPS for 60s → p99 ≤ 200ms

---

### Q-Dec.task-1.observable-1: partial vs full update

**Cited item**: `task-1.observable-1`

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. PATCH with field subset → only listed fields change. Omitted fields untouched. (RFC 7396 merge patch)
- B. PATCH with full object → entire record replaced; missing fields cleared.
- C. other (write own)

**Developer answer**: A
**Source**: `problem.md#criterion-2` ("RESTful conventions, RFC 7396 merge patch")
**Critique log**: clean

**Test spec (auto-derived)**:
- Existing user with `bio: "old"` → `PATCH /users/123 {"display_name": "X"}` → record now `{display_name: "X", email: <unchanged>, bio: "old"}`
- Existing user → `PATCH /users/123 {"bio": null}` → record now `{... bio: null}`

---

### Q-Edge.task-1.observable-1: unknown user id

**Cited item**: `task-1.observable-1`

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. 404 with `{error: "user_not_found"}`
- B. 401 (do not reveal whether user exists)
- C. other (write own)

**Developer answer**: B
**Source**: `problem.md#invariant-1` ("auth must not leak user existence")
**Critique log**:
- Turn 11 — agent: "shouldn't this be 404? typical REST." → developer cited invariant-1; correct call is 401 to avoid existence oracle

**Test spec (auto-derived)**:
- Authenticated request to `PATCH /users/9999999` (non-existent) → 401, no body details

---

### Q-Fail.task-1.observable-3: 4xx envelope content

**Cited item**: `task-1.observable-3`

**Expected answer shape**: free text (≤ 60 words; show JSON)

**Developer answer**:

```json
{
  "errors": [
    {"field": "email", "message": "Enter a valid email address."}
  ]
}
```

For non-field errors: `{"errors": [{"message": "..."}]}` with no `field`.

**Source**: `tasks.md#task-1.observable-3` + discussion turn 13

**Test spec (auto-derived)**:
- Invalid email → 422 with `errors[0].field == "email"` and human-readable message

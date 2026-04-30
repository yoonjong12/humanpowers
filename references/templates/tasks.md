# Tasks

> Output of `humanpowers:writing-plans` (preliminary outline comes from `humanpowers:brainstorming` task outline). One section per task. Items inside each task carry stable IDs (`task-N.observable-N`, `task-N.verify-condition-N`, `task-N.constraint-N`, `task-N.assumption-N`, `task-N.dependency-N`) so the quiz can cite them and downstream artifacts (plan, verify, ADR digest) can trace decisions to specific items.

## task-1: <short descriptive name>

**WHO**: <persona — the user role this task serves>
**WHY**: <value hypothesis — one line>
**ACTION_TYPE**: ui | api | data | infra | cross-cutting
**DEPENDS_ON**: []  # list of task IDs (e.g., [task-2, task-3]) that must be `verified` before this one starts
**STATUS**: brainstorm-done | quiz-done | designed | built | verified

### Observables (`task-1.observable-N`)

What observable changes does this task introduce? File paths, API shapes, DB columns, UI elements — anything an outside reader can see without reading the implementation.

- task-1.observable-1: <observable change>
- task-1.observable-2: <observable change>

### Verify conditions (`task-1.verify-condition-N`)

Concrete pass criteria. Each condition must be checkable: a curl response shape, a SQL row count, a Gherkin scenario, a checklist item.

- task-1.verify-condition-1: <test or demo condition>

### Constraints (`task-1.constraint-N`)

Task-local non-functional requirements. Quantitative bounds (latency, size cap, count cap), qualitative invariants (no PII in logs), prohibitions.

- task-1.constraint-1: <bound or prohibition>

### Assumptions (`task-1.assumption-N`)

What is taken as given for this task: input shape, prior data state, environment configuration, upstream behavior. If an assumption later proves wrong, the task may need to return to brainstorming.

- task-1.assumption-1: <precondition>

### Dependencies (`task-1.dependency-N`)

Inputs and preconditions sourced from elsewhere — another task's output, an external service, a config value, a library version. Distinct from `DEPENDS_ON` (which is a task-graph edge); this lists the actual artifacts the task consumes.

- task-1.dependency-1: <input source>

---

## task-2: <short descriptive name>

(Same structure. Repeat per task.)

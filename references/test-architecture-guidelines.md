# Test Architecture Guidelines

TDD tells you to write tests first. This document tells you how to design tests that survive accumulation — when multiple tasks, refactors, and iterations layer on top of each other.

## The accumulation problem

TDD per-task produces one test per behavior per task. When task-2 touches the same module as task-1, both produce tests for overlapping behavior. After 5 tasks, the same assertion lives in 3 files. Nobody notices because each task's tests pass in isolation.

Symptoms: 3-way duplicate tests, dead test arguments, test files that test the same behavior under different names, tests that break on refactor because they test implementation instead of behavior.

## Test ownership rule

One behavior = one test = one owner.

| Layer | What it owns | Scope |
|-------|-------------|-------|
| Unit test | Single function/method behavior | Input → output, no I/O |
| Integration test | Contract between components | Does A talk to B correctly? |
| E2E / pipeline test | User-visible workflow | Full path, real dependencies |

When a new task adds behavior to an existing module:
1. Check if the behavior is already tested (grep for the function name in tests/)
2. If tested → extend the existing test, don't create a parallel one
3. If not tested → create the test in the file that owns that module's tests

## Test file placement

Test file mirrors source file. `src/parser/response.py` → `tests/parser/test_response.py`.

One test file per source file. If `test_response.py` exists, new tests for `response.py` go there — not in `test_response_pcr.py` or `test_parser_pcr.py`.

Exception: integration tests that span multiple modules get their own file named by the workflow they test (`test_pipeline_integration.py`, `test_feedback_roundtrip.py`).

## Before writing a new test

```
1. IDENTIFY: What behavior am I testing?
2. SEARCH: grep -r "def test_.*{keyword}" tests/
3. CHECK: Does an existing test already assert this?
   - YES → extend or parametrize the existing test
   - NO → write the new test in the module's owner file
4. NEVER: Create a new test file for behavior already covered elsewhere
```

## Test DRY patterns

### Shared fixtures over duplicated setup

```python
# BAD: same setup in 3 test files
class TestA:
    def test_x(self):
        engine = create_engine()
        session = Session(engine)
        ...

class TestB:
    def test_y(self):
        engine = create_engine()
        session = Session(engine)
        ...

# GOOD: shared fixture
@pytest.fixture
def session():
    engine = create_engine()
    return Session(engine)
```

### Parametrize over copy-paste

```python
# BAD: 3 tests that differ only in input
def test_parse_json(): ...
def test_parse_yaml(): ...
def test_parse_toml(): ...

# GOOD: 1 parametrized test
@pytest.mark.parametrize("fmt,input,expected", [...])
def test_parse(fmt, input, expected): ...
```

### Test behavior, not implementation

```python
# BAD: tests internal method call order (breaks on refactor)
mock_db.get.assert_called_once_with(id=1)

# GOOD: tests observable output (survives refactor)
assert result.name == "expected"
```

## Post-task test hygiene

After completing a task's TDD cycle, before marking `built`:

1. **Duplicate scan:** Does any new test assert the same thing as an existing test? If yes, keep the more specific one, delete the other.
2. **Dead argument check:** Does any test pass arguments that the function under test doesn't use? Remove them.
3. **File placement check:** Is the new test in the correct owner file? If it landed in a convenience file during development, move it.

## Cross-task test consolidation (during review)

When `humanpowers:review` runs after multiple tasks are verified:

1. Scan `tests/` for functions testing the same behavior (same assertions, different setups or names).
2. Flag duplicates to the developer with source locations.
3. Developer decides: merge, keep both (if they test genuinely different scenarios), or delete.

This is not automated cleanup — the developer makes the call.

## Anti-patterns

| Anti-pattern | Signal | Fix |
|-------------|--------|-----|
| Parallel test file | `test_foo.py` and `test_foo_bar.py` both testing `foo.py` | Merge into `test_foo.py` |
| Factory-only test | Test creates objects but never asserts behavior | Delete or add meaningful assertion |
| Mock-the-world | Test mocks 5 dependencies, tests that mocks were called | Replace with integration test or test real behavior |
| Copy-paste test | Same test body in 2+ files, different class name | Parametrize or keep one |
| Dead argument | `llm=_mock_llm()` passed but function ignores it | Remove argument |

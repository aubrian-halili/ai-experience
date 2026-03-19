# Testing

## Iron Laws

- **No production code without a failing test first** — if code was written before the test, delete it and start over
- **Never mock what you don't own** — only mock code you control; use real implementations or test doubles for third-party code
- **Behavior not implementation** — tests should survive refactors; test inputs/outputs, not internal calls

## TDD Cycle

1. **RED** — write a failing test; verify it fails with an expected assertion error (not a syntax error)
2. **GREEN** — write the minimum production code to pass the test
3. **REFACTOR** — clean up without changing behavior; all tests must still pass

## Testing Pyramid

| Level | Quantity | Focus |
|-------|----------|-------|
| Unit | 70% | Single function/class, fast |
| Integration | 20% | Component interactions |
| E2E | 10% | Full user flows |

## Coverage Targets

- Statements/Functions/Lines: > 80%
- Branches: > 75%

## Test Naming

Use `should [expected behavior] when [condition]` format.

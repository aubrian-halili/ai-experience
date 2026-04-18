# Testing

## Iron Laws

- **No production code without a failing test first** — write the test, verify it fails with an assertion error (not a syntax error), then write the minimum code to pass
- **Never mock what you don't own** — only mock code you control; use real implementations or test doubles for third-party code
- **Behavior not implementation** — tests should survive refactors; test inputs/outputs, not internal calls
## Testing Pyramid

Target mix: ~70% unit, 20% integration, 10% E2E

## Coverage Targets

- Statements/Functions/Lines: > 80%
- Branches: > 75%

## Test Naming

Use `should [expected behavior] when [condition]` format.

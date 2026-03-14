---
name: testing
description: >-
  User asks to "write tests", "add test coverage", "test strategy", mentions
  "unit test", "integration test", "TDD", or wants to generate test code.
  Not for: code review mentioning test gaps (use /review), verifying completeness
  (use /verify), debugging a failing test (use /debug).
argument-hint: "[file, feature, or component to test]"
allowed-tools: Read, Grep, Glob, Write
---

Provide comprehensive testing guidance, test scaffolding, and coverage analysis following the testing pyramid principles.

## Testing Philosophy

- **Test pyramid discipline** — follow the 70/20/10 ratio (unit/integration/E2E); push testing to the lowest effective level
- **Isolation by default** — each test runs independently with no shared mutable state; parallel execution must be safe
- **Determinism over coverage** — a flaky test is worse than a missing test; eliminate non-deterministic behavior before adding coverage
- **Fast feedback loop** — unit tests run in seconds, integration tests in minutes; slow tests indicate wrong test level
- **Behavior, not implementation** — test what the code does (inputs/outputs, side effects), not how it does it; refactors should not break tests

## Iron Laws

> - NO production code without a failing test first
> - If you wrote code before the test, delete it and start over
> - Never mock what you don't own

The delete-and-restart rule is non-negotiable:

**Bad** — "I'll keep what I wrote and add tests around it":
```typescript
// You already wrote this working function
function calculateDiscount(price: number, tier: string): number {
  if (tier === 'gold') return price * 0.2;
  if (tier === 'silver') return price * 0.1;
  return 0;
}

// Now you write a test that just confirms what you already know works
it('should return 20% for gold', () => {
  expect(calculateDiscount(100, 'gold')).toBe(20); // ← you already know this passes
});
// This test was shaped by the implementation, not by the requirement
```

**Good** — delete the code, start from the test:
```typescript
// Start with what the business requires, not what you already coded
it('should apply no discount for unknown tiers', () => {
  expect(calculateDiscount(100, 'bronze')).toBe(0);
});

it('should apply 10% discount for silver tier', () => {
  expect(calculateDiscount(100, 'silver')).toBe(10);
});

// Run → RED. Now write the minimal code to pass. You'll discover
// edge cases (negative prices? empty string tier?) that the
// code-first approach would have missed.
```

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple paths are where wrong assumptions live |
| "Integration tests cover this" | Unit and integration tests answer different questions |
| "I'll add tests later" | Tests-later means tests-never; coverage debt compounds |
| "Mocking is too complex here" | Complex mocking signals wrong abstraction boundaries |
| "Tests after achieve the same goals" | Tests-after answer "what does this do?"; tests-first answer "what should this do?" — fundamentally different design feedback |
| "Need to explore the problem first" | Exploration is fine, but throw away the spike and start over with TDD. Spikes are for learning, not shipping. |
| "I already manually tested it" | Ad-hoc testing leaves no record, can't be re-run, and misses edge cases. Manual ≠ systematic. |
| "I'll keep the code as reference" | You'll adapt it instead of deleting it. "Keep as reference" is "keep as production" with extra steps. Delete means delete. |
| "This is hard to test" | Listen to the test. Hard to test = hard to use. The difficulty is design feedback, not an excuse to skip. |

## Red Flags — STOP and Start Over

If any of these conditions are true, stop what you're doing. Delete the code and restart with a failing test:

- **Code written before test** — you're already doing tests-after. The test will be shaped by the implementation, not the requirement.
- **Test passes immediately on first run** — either the behavior already exists (find out why) or the test doesn't assert what you think it does.
- **Can't explain why the test failed** — if the RED step produces an error you didn't expect, you don't understand the code well enough yet. Investigate before writing production code.
- **Rationalizing "just this once"** — check the Rationalization Guard above. If you're making an excuse, that's the signal to be more disciplined, not less.
- **Test requires more setup than production code** — the test is telling you the design is too coupled. Simplify the design first.

## Input Handling

Classify `$ARGUMENTS` to determine the testing scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Determine test target | Ask user to specify scope |
| File path (e.g., `src/auth/login.ts`) | Test specific file | Analyze exports, generate unit tests |
| Directory path (e.g., `src/auth/`) | Test directory files | Systematic analysis, prioritize by complexity |
| Component name (e.g., `AuthService`) | Test component | Locate component, generate tests for matches |
| Feature description (e.g., `payment flow`) | Test feature end-to-end | Trace feature, tests at all pyramid levels |
| Coverage request (e.g., `improve coverage`) | Analyze coverage gaps | Run coverage analysis, report untested paths |

## Process

### 1. Pre-flight

- Classify testing scope from `$ARGUMENTS` using the Input Handling table
- Verify target files/components exist via Glob and Read
- Detect test framework and runner: search for `jest.config`, `vitest.config`, `mocha`, `.mocharc`, `playwright.config`, or `cypress.config`
- Check for existing tests: search `tests/`, `__tests__/`, `*.test.ts`, `*.spec.ts` near the target
- Check CLAUDE.md and project conventions for testing standards

**Stop conditions:**
- No `$ARGUMENTS` and no obvious test target → ask user what to test
- Target file or component not found → report missing path, ask user to verify
- No test framework detected → recommend setup based on project type (step 2), confirm before proceeding
- Target is a test file itself → clarify whether to debug, refactor, or extend the existing tests

### 2. Determine Test Strategy

Map the target code to test types using this guide:

| Code Type | Primary Test Type | Focus |
|-----------|------------------|-------|
| Pure functions | Unit | Input/output correctness |
| Classes with dependencies | Unit + mocks | Behavior verification |
| API endpoints | Integration | Request/response cycle |
| Database operations | Integration | Data persistence |
| User flows | E2E | End-to-end behavior |

Apply the Testing Pyramid ratios to determine test distribution:

| Level | Quantity | Speed | Scope |
|-------|----------|-------|-------|
| Unit | Many (70%) | Fast | Single function/class |
| Integration | Some (20%) | Medium | Component interactions |
| E2E | Few (10%) | Slow | Full user flows |

- Identify dependencies that need mocking or stubbing
- For coverage gap requests: run existing coverage first, identify uncovered branches and functions
- Cross-reference with `@references/patterns.md` for async, timer, and error boundary patterns

### 3. Write Tests

Follow the AAA pattern (Arrange, Act, Assert) for every test case.

- **Arrange**: Set up test data, mocks, and preconditions
- **Act**: Execute the function or trigger the behavior under test
- **Assert**: Verify outputs, side effects, and state changes
- Use descriptive test names: `should [expected behavior] when [condition]`
- Group tests by behavior using `describe` blocks (happy path, edge cases, error handling)
- See `@references/templates.md` for full scaffolding examples (unit, integration, E2E, test data, mocking)
- See `@references/anti-patterns.md` for mocking pitfalls and gate functions

#### Good vs Bad Test Examples

**Good** — clear name, one behavior, tests real logic:
```typescript
it('should normalize email to lowercase when creating account', async () => {
  const account = await createAccount({ email: 'User@Example.COM' });
  expect(account.email).toBe('user@example.com');
});
```

**Bad** — vague name, tests the mock, multiple concerns:
```typescript
it('should work correctly', async () => {
  const mockDb = { save: jest.fn().mockResolvedValue({ id: 1 }) };
  const account = await createAccount({ email: 'test@test.com' }, mockDb);
  expect(mockDb.save).toHaveBeenCalled(); // tests the mock, not the behavior
  expect(account.id).toBe(1); // proves the mock returns what you told it to
  expect(account.email).toBeDefined(); // asserts nothing meaningful
});
```

#### TDD: RED-GREEN-REFACTOR Verification

When practicing TDD, treat each phase as a mandatory checkpoint:

1. **RED — Write a failing test**
   - Write the test for the next behavior
   - Run: `npm test -- --testPathPattern=<test-file>`
   - **Verify**: the new test fails with an expected assertion error (not a syntax or import error)
   - If the test passes immediately → STOP. Either the behavior already exists or the test is wrong.

2. **GREEN — Write minimal code to pass**
   - Write only enough production code to make the failing test pass
   - Run: `npm test -- --testPathPattern=<test-file>`
   - **Verify**: the new test passes AND all existing tests still pass
   - If any existing test broke → you changed too much. Revert and take a smaller step.

3. **REFACTOR — Clean up without changing behavior**
   - Improve code structure (extract, rename, simplify)
   - Run: `npm test` (full suite)
   - **Verify**: all tests still pass with no changes to test code
   - If a test fails → the refactor changed behavior. Revert and try again.

### 4. Verify Test Quality

- Run the full test suite to confirm all new tests pass
- Check for test isolation: no shared mutable state, no test order dependencies
- Validate determinism: tests produce the same result on repeated runs
- Confirm tests follow the "behavior, not implementation" principle from Testing Philosophy
- If tests are flaky, diagnose and fix before proceeding (see `@references/patterns.md` for async patterns)

### 5. Coverage Analysis

Target thresholds:

| Metric | Target |
|--------|--------|
| Statements | > 80% |
| Branches | > 75% |
| Functions | > 80% |
| Lines | > 80% |

- Run coverage report and compare against targets
- Identify uncovered critical paths, error branches, and edge cases
- Prioritize coverage gaps by risk: error handling and security paths first
- For coverage gap requests: present a prioritized list of files/functions to test next

### 6. Diagnose Failures

- If all tests pass, skip to Verify
- Read the test file and the target source code
- Identify failure type: assertion mismatch, runtime error, timeout, setup/teardown issue
- Check for common causes: stale mocks, changed API contracts, non-deterministic behavior (timers, network)
- Propose a fix with before/after diff example
- If the failure reveals a bug in the source code (not the test), flag it and recommend `/review`

### 7. Verify

- Confirm all applicable test levels (unit, integration, E2E) were addressed; note any skipped levels with rationale
- Review generated tests against the Testing Pyramid ratios; flag significant imbalances (e.g., all E2E, no unit tests)
- If coverage analysis was performed, present before/after comparison and confirm targets from step 5 were met or gaps documented
- Suggest next steps: remaining coverage gaps, related skills (`/review` for test quality, `/security` for security tests), or state test completeness with confidence level

## Output Principles

- **Test-first ordering** — present test cases grouped by test level (unit first, then integration, then E2E), matching the testing pyramid priority
- **Descriptive naming** — every test name follows `should [behavior] when [condition]` format; test names are the documentation
- **Concrete examples** — show complete, runnable test code with realistic test data; never show pseudo-code placeholders
- **Coverage context** — when reporting coverage, always show before/after comparison and highlight the specific gaps addressed

## Error Handling

| Scenario | Response |
|----------|----------|
| No test framework detected | Recommend setup based on project type, confirm before proceeding |
| Target file not found | Report the missing path and ask user to verify |
| Low coverage | Prioritize critical paths first; present a ranked list of coverage gaps |
| Flaky tests | Identify non-deterministic behavior (timers, network, shared state); fix before adding coverage |
| Slow test suite | Suggest optimization: move tests down the pyramid, parallelize, reduce setup overhead |
| Existing tests conflict | Review existing tests first, propose additions that complement rather than duplicate |
| Test framework mismatch | Detect project conventions, adapt templates to the framework in use |
| Scope too broad (>20 files) | Prioritize by risk and coverage gaps, note files not covered |

Never silently skip test levels or coverage gaps—surface what was tested, what was not, and why.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review existing test quality |
| `/feature` | Test planning as part of feature development |
| `/security` | Security-focused testing |
| `/clean-code` | Refactor test code for maintainability |
| `/explore` | Understand codebase context before testing unfamiliar code |
| `/debug` | Investigate a failing test or unexpected behavior |
| `/typescript` | Type-safe mocks, generics in test utilities |

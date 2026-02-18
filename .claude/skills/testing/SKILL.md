---
name: testing
description: Use when the user asks to "write tests", "add test coverage", "test this feature", "create test cases", mentions "unit test", "integration test", "E2E test", "test strategy", or needs testing guidance and test scaffolding.
argument-hint: "[file, feature, or component to test]"
allowed-tools: Read, Grep, Glob, Write
---

Provide comprehensive testing guidance, test scaffolding, and coverage analysis following the testing pyramid principles.

## When to Use

### This Skill Is For

- Writing unit, integration, and E2E tests
- Creating test strategies for features
- Analyzing and improving test coverage
- Test-driven development (TDD) guidance
- Setting up testing infrastructure
- Debugging failing tests

### Use a Different Approach When

- Reviewing existing tests for quality → use `/review`
- Security testing specifically → use `/security`
- Performance testing → consult performance testing tools

## Testing Pyramid

| Level | Quantity | Speed | Scope |
|-------|----------|-------|-------|
| Unit | Many (70%) | Fast | Single function/class |
| Integration | Some (20%) | Medium | Component interactions |
| E2E | Few (10%) | Slow | Full user flows |

## Process

Use `$ARGUMENTS` if provided (file path, feature name, or component to test).

### 1. Analyze Test Target

Identify what needs testing: functions/methods, class behaviors, API endpoints, user workflows, edge cases, and error handling.

### 2. Determine Test Strategy

| Code Type | Primary Test Type | Focus |
|-----------|------------------|-------|
| Pure functions | Unit | Input/output correctness |
| Classes with deps | Unit + mocks | Behavior verification |
| API endpoints | Integration | Request/response cycle |
| Database operations | Integration | Data persistence |
| User flows | E2E | End-to-end behavior |

### 3. Write Tests

Follow the AAA pattern (Arrange, Act, Assert). See `@references/templates.md` for full test scaffolding examples (unit, integration, E2E, test data, mocking).

### 4. Coverage Analysis

Target: Statements > 80%, Branches > 75%, Functions > 80%, Lines > 80%.

See `@references/patterns.md` for testing async code, timers, and error boundaries.

## Error Handling

| Scenario | Response |
|----------|----------|
| No test framework detected | Recommend setup based on project type |
| Low coverage | Prioritize critical paths first |
| Flaky tests | Identify non-deterministic behavior |
| Slow tests | Suggest optimization strategies |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review existing test quality |
| `/feature` | Test planning as part of feature development |
| `/security` | Security-focused testing |
| `/clean-code` | Refactor test code for maintainability |

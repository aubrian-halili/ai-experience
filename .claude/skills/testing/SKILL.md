---
name: testing
description: Use when the user asks to "write tests", "add test coverage", "test this feature", "create test cases", mentions "unit test", "integration test", "E2E test", "test strategy", or needs testing guidance and test scaffolding.
argument-hint: "[file, feature, or component to test]"
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

```
        /\
       /  \
      / E2E \      Few, slow, high confidence
     /--------\
    /Integration\   Some, medium speed
   /--------------\
  /    Unit Tests   \  Many, fast, focused
 /--------------------\
```

| Level | Quantity | Speed | Scope |
|-------|----------|-------|-------|
| Unit | Many (70%) | Fast | Single function/class |
| Integration | Some (20%) | Medium | Component interactions |
| E2E | Few (10%) | Slow | Full user flows |

## Process

### 1. Analyze Test Target

Identify what needs testing:
- Functions and methods
- Class behaviors
- API endpoints
- User workflows
- Edge cases and error handling

### 2. Determine Test Strategy

| Code Type | Primary Test Type | Focus |
|-----------|------------------|-------|
| Pure functions | Unit | Input/output correctness |
| Classes with deps | Unit + mocks | Behavior verification |
| API endpoints | Integration | Request/response cycle |
| Database operations | Integration | Data persistence |
| User flows | E2E | End-to-end behavior |

### 3. Write Tests

Follow the AAA pattern:
- **Arrange**: Set up test data and conditions
- **Act**: Execute the code under test
- **Assert**: Verify the expected outcome

### 4. Coverage Analysis

```bash
# Generate coverage report
npm test -- --coverage

# View uncovered lines
npm test -- --coverage --coverageReporters=text
```

Target coverage:
- Statements: > 80%
- Branches: > 75%
- Functions: > 80%
- Lines: > 80%

## Response Format

```markdown
## Testing Plan

**Target**: [File/Feature/Component]
**Test Framework**: [Jest | Vitest | Mocha | etc.]
**Current Coverage**: [X%] → **Target**: [Y%]

---

### Test Strategy

| Layer | Tests Needed | Priority |
|-------|-------------|----------|
| Unit | [Count] | High |
| Integration | [Count] | Medium |
| E2E | [Count] | Low |

### Test Cases

#### Unit Tests

**File**: `tests/unit/[target].test.ts`

```typescript
import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { TargetFunction } from '../src/target';

describe('TargetFunction', () => {
  describe('happy path', () => {
    it('should return expected result for valid input', () => {
      // Arrange
      const input = { /* test data */ };

      // Act
      const result = TargetFunction(input);

      // Assert
      expect(result).toEqual({ /* expected */ });
    });
  });

  describe('edge cases', () => {
    it('should handle empty input', () => {
      expect(TargetFunction({})).toBeNull();
    });

    it('should handle null input', () => {
      expect(() => TargetFunction(null)).toThrow('Invalid input');
    });
  });

  describe('error handling', () => {
    it('should throw on invalid data', () => {
      expect(() => TargetFunction({ invalid: true }))
        .toThrow(ValidationError);
    });
  });
});
```

#### Integration Tests

**File**: `tests/integration/[target].test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import request from 'supertest';
import { app } from '../src/app';
import { db } from '../src/database';

describe('API: /api/target', () => {
  beforeAll(async () => {
    await db.connect();
    await db.seed();
  });

  afterAll(async () => {
    await db.cleanup();
    await db.disconnect();
  });

  describe('GET /api/target', () => {
    it('should return list of items', async () => {
      const response = await request(app)
        .get('/api/target')
        .expect(200);

      expect(response.body).toHaveLength(3);
      expect(response.body[0]).toHaveProperty('id');
    });

    it('should filter by query param', async () => {
      const response = await request(app)
        .get('/api/target?status=active')
        .expect(200);

      expect(response.body.every(item => item.status === 'active')).toBe(true);
    });
  });

  describe('POST /api/target', () => {
    it('should create new item', async () => {
      const newItem = { name: 'Test', value: 123 };

      const response = await request(app)
        .post('/api/target')
        .send(newItem)
        .expect(201);

      expect(response.body.id).toBeDefined();
      expect(response.body.name).toBe('Test');
    });

    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/api/target')
        .send({})
        .expect(400);

      expect(response.body.error).toContain('name is required');
    });
  });
});
```

#### E2E Tests

**File**: `tests/e2e/[flow].test.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Flow: [Feature Name]', () => {
  test('complete user journey', async ({ page }) => {
    // Navigate to starting point
    await page.goto('/');

    // Step 1: User action
    await page.click('[data-testid="start-button"]');

    // Step 2: Fill form
    await page.fill('[data-testid="name-input"]', 'Test User');
    await page.click('[data-testid="submit-button"]');

    // Step 3: Verify result
    await expect(page.locator('[data-testid="success-message"]'))
      .toBeVisible();
    await expect(page.locator('[data-testid="user-name"]'))
      .toHaveText('Test User');
  });
});
```

### Test Data Management

```typescript
// fixtures/testData.ts
export const validUser = {
  id: 'test-user-1',
  name: 'Test User',
  email: 'test@example.com',
};

export const invalidInputs = [
  { input: null, error: 'Input required' },
  { input: {}, error: 'Name required' },
  { input: { name: '' }, error: 'Name cannot be empty' },
];
```

### Mocking Strategy

```typescript
// Mocking external dependencies
jest.mock('../src/external-service', () => ({
  fetchData: jest.fn().mockResolvedValue({ data: 'mocked' }),
}));

// Mocking database
jest.mock('../src/database', () => ({
  query: jest.fn().mockResolvedValue([{ id: 1 }]),
}));
```

### Coverage Gaps

| File | Current | Gap | Priority |
|------|---------|-----|----------|
| `src/target.ts` | 60% | Missing edge cases | High |
| `src/utils.ts` | 85% | Error paths | Medium |

### Commands

```bash
# Run all tests
npm test

# Run specific test file
npm test -- tests/unit/target.test.ts

# Run with coverage
npm test -- --coverage

# Run in watch mode
npm test -- --watch

# Run E2E tests
npm run test:e2e
```
```

## Test Patterns

### Testing Async Code

```typescript
it('should handle async operation', async () => {
  const result = await asyncFunction();
  expect(result).toBeDefined();
});

it('should reject on error', async () => {
  await expect(asyncFunction()).rejects.toThrow('Error message');
});
```

### Testing with Timers

```typescript
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});

it('should timeout after delay', () => {
  const callback = jest.fn();
  setTimeout(callback, 1000);

  jest.advanceTimersByTime(1000);

  expect(callback).toHaveBeenCalled();
});
```

### Testing Error Boundaries

```typescript
it('should handle errors gracefully', () => {
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

  expect(() => riskyOperation()).not.toThrow();
  expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Error'));

  consoleSpy.mockRestore();
});
```

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

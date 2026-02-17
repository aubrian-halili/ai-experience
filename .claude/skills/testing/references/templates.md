# Testing Plan Template

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

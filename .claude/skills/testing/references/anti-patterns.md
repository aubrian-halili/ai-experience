# Testing Anti-Patterns

## 1. Testing Mock Behavior Instead of Real Behavior

The most common and dangerous anti-pattern: your test passes because the mock does what you told it to, not because the code actually works.

**Bad** — tests the mock, not the code:
```typescript
it('should fetch user data', async () => {
  const mockDb = { findUser: jest.fn().mockResolvedValue({ id: 1, name: 'Alice' }) };
  const service = new UserService(mockDb);

  const user = await service.getUser(1);

  // This only proves the mock returns what you told it to return
  expect(mockDb.findUser).toHaveBeenCalledWith(1);
  expect(user.name).toBe('Alice');
});
```

**Good** — tests real behavior through the dependency:
```typescript
it('should return user with normalized name', async () => {
  // Use a real in-memory database or test container
  await db.insert({ id: 1, name: '  alice  ' });
  const service = new UserService(db);

  const user = await service.getUser(1);

  // Tests the actual transformation the service performs
  expect(user.name).toBe('Alice');
});
```

**Gate Function**: Before writing a mock, ask:
> "If I replaced the mock return value with something completely different, would this test still pass?"
> If yes → you're testing the mock, not the code.

## 2. Test-Only Methods in Production Classes

Adding methods to production code solely to make testing easier pollutes the API surface and creates maintenance burden.

**Bad** — production code shaped by test needs:
```typescript
class PaymentProcessor {
  private retryCount = 0;

  async processPayment(amount: number): Promise<Result> {
    // ... real logic
  }

  // Added only for testing — leaks internal state
  getRetryCount(): number {
    return this.retryCount;
  }

  // Added only for testing — bypasses real behavior
  _resetState(): void {
    this.retryCount = 0;
  }
}
```

**Good** — test through public behavior:
```typescript
it('should retry failed payments up to 3 times', async () => {
  const gateway = createFailingGateway({ failCount: 2 });
  const processor = new PaymentProcessor(gateway);

  const result = await processor.processPayment(100);

  // Verify the observable outcome, not internal state
  expect(result.status).toBe('success');
  expect(gateway.attemptCount).toBe(3);
});
```

**Gate Function**: Before adding a method or making something public, ask:
> "Would I add this method if I weren't writing tests?"
> If no → find another way to observe the behavior.

## 3. Mocking Without Understanding the Dependency

Mocking a dependency you don't fully understand creates a false contract. When the real dependency changes behavior, your tests keep passing while production breaks.

**Bad** — mock based on assumptions:
```typescript
jest.mock('stripe', () => ({
  charges: {
    create: jest.fn().mockResolvedValue({ id: 'ch_123', status: 'succeeded' }),
  },
}));

it('should create a charge', async () => {
  // This test will pass even if Stripe's API changes completely
  const result = await billingService.charge(1000, 'usd');
  expect(result.chargeId).toBe('ch_123');
});
```

**Good** — mock based on documented contract:
```typescript
// Create a mock that mirrors Stripe's actual response shape
// Reference: https://stripe.com/docs/api/charges/create
const stripeCharge: Stripe.Charge = {
  id: 'ch_123',
  object: 'charge',
  amount: 1000,
  currency: 'usd',
  status: 'succeeded',
  // Include fields your code actually uses
  paid: true,
  refunded: false,
};

it('should map Stripe charge to internal billing record', async () => {
  stripeMock.charges.create.mockResolvedValue(stripeCharge);

  const record = await billingService.charge(1000, 'usd');

  expect(record).toEqual({
    externalId: 'ch_123',
    amount: 1000,
    currency: 'usd',
    status: 'paid',
  });
});
```

**Gate Function**: Before mocking an external dependency, ask:
> "Can I point to documentation or source code that confirms this mock matches the real behavior?"
> If no → read the docs first. An incorrect mock is worse than no test.

## 4. Incomplete Mocks That Hide Bugs

Partially mocking a dependency — replacing some methods but not others — creates a chimera that behaves unlike anything in production.

**Bad** — partial mock hides missing error handling:
```typescript
const mockCache = {
  get: jest.fn().mockResolvedValue(null),
  set: jest.fn().mockResolvedValue(undefined),
  // Missing: delete, clear, disconnect, error events
};

it('should fall back to database on cache miss', async () => {
  const service = new DataService(mockCache, db);
  const result = await service.getData('key-1');

  // Passes, but what happens when cache.disconnect() is called in cleanup?
  // Or when cache emits an error event?
  expect(result).toEqual(dbRecord);
});
```

**Good** — complete interface implementation:
```typescript
// Implement the full interface so TypeScript catches missing methods
class FakeCache implements CacheClient {
  private store = new Map<string, string>();

  async get(key: string): Promise<string | null> {
    return this.store.get(key) ?? null;
  }

  async set(key: string, value: string, ttl?: number): Promise<void> {
    this.store.set(key, value);
  }

  async delete(key: string): Promise<boolean> {
    return this.store.delete(key);
  }

  async clear(): Promise<void> {
    this.store.clear();
  }

  async disconnect(): Promise<void> {
    this.store.clear();
  }
}
```

**Gate Function**: Before using a partial mock, ask:
> "Does this mock implement the full interface my code depends on?"
> If no → use a fake that implements the complete interface, or use the real dependency.

## 5. Testing Implementation Details via Spy Overuse

Over-relying on `toHaveBeenCalledWith` to verify internal method calls couples tests to implementation. Refactoring breaks tests even when behavior is preserved.

**Bad** — tests the call chain, not the outcome:
```typescript
it('should process order', async () => {
  const validateSpy = jest.spyOn(orderService, 'validate');
  const calculateSpy = jest.spyOn(orderService, 'calculateTotal');
  const saveSpy = jest.spyOn(orderService, 'save');

  await orderService.processOrder(order);

  expect(validateSpy).toHaveBeenCalledWith(order);
  expect(calculateSpy).toHaveBeenCalledWith(order.items);
  expect(saveSpy).toHaveBeenCalledWith(expect.objectContaining({ total: 100 }));
});
```

**Good** — tests the observable result:
```typescript
it('should process order and persist with calculated total', async () => {
  const order = createOrder({ items: [{ price: 50, qty: 2 }] });

  const result = await orderService.processOrder(order);

  expect(result.status).toBe('confirmed');
  expect(result.total).toBe(100);

  // Verify side effect through the boundary, not internal calls
  const saved = await orderRepository.findById(result.id);
  expect(saved.total).toBe(100);
});
```

**Gate Function**: Before adding a spy assertion, ask:
> "If I refactored the internals but kept the same inputs and outputs, would this test break?"
> If yes → you're testing implementation, not behavior. Assert on outcomes instead.

# Test Patterns

## Testing Async Code

```typescript
it('should handle async operation', async () => {
  const result = await asyncFunction();
  expect(result).toBeDefined();
});

it('should reject on error', async () => {
  await expect(asyncFunction()).rejects.toThrow('Error message');
});
```

## Testing with Timers

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

## Testing Error Boundaries

```typescript
it('should handle errors gracefully', () => {
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

  expect(() => riskyOperation()).not.toThrow();
  expect(consoleSpy).toHaveBeenCalledWith(expect.stringContaining('Error'));

  consoleSpy.mockRestore();
});
```

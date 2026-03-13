# Root Cause Tracing

## 5-Step Backward Trace

When you find where an error manifests, trace backward — never fix at the symptom site.

1. **Observe the symptom** — exact error message, wrong value, unexpected state
2. **Find the immediate cause** — the line that produces the wrong result
3. **Ask "what called this?"** — trace one level up the call chain
4. **Keep tracing up** — repeat step 3 until you find where correct data becomes incorrect
5. **Find the original trigger** — the first point where invalid state enters the system

## When to Add Stack Trace Instrumentation

If the call chain is unclear or involves async/event-driven code:

```typescript
// Temporary instrumentation — remove before committing
console.log('DEBUG [component:function]', {
  input: relevantInput,
  state: relevantState,
  stack: new Error().stack
});
```

Add instrumentation at each level of the call chain, then run once to see the full path.

## Key Principle

**NEVER fix just where the error appears.** The symptom site is rarely the root cause.

| Scenario | Symptom Site | Likely Root Cause |
|----------|-------------|-------------------|
| `TypeError: Cannot read property of undefined` | The property access | Whatever should have set the value but didn't |
| Wrong API response | The response handler | The request construction or upstream data |
| UI shows stale data | The render function | The state update or cache invalidation |
| Off-by-one error | The loop or index access | The boundary calculation or initial value |

## When to Stop Tracing

Stop when you find the point where:
- External input enters the system without proper validation
- A function contract is violated (receives data it shouldn't)
- State mutation happens outside its expected lifecycle
- An assumption in the code no longer holds true

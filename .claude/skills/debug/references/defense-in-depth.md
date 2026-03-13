# Defense in Depth

## When to Apply

After fixing any bug caused by invalid data flowing through multiple layers unchecked. If bad data passed through 2+ components before causing an error, a single fix at the root cause is necessary but may not be sufficient.

## 4-Layer Validation Pattern

After fixing the root cause, check whether validation exists at each layer the data passes through:

| Layer | Purpose | Example |
|-------|---------|---------|
| **Entry point** | Reject invalid input at the system boundary | API request validation, form input sanitization |
| **Business logic** | Enforce domain invariants | Null checks, range validation, state machine guards |
| **Environment guards** | Verify runtime assumptions | Config presence, service availability, feature flags |
| **Debug instrumentation** | Catch violations during development | Assertions, debug-only logging, type narrowing |

## Key Insight

A single validation point is insufficient because different code paths bypass different layers.

| Scenario | Why Single Validation Fails |
|----------|----------------------------|
| New API endpoint added | Skips the validation in the old endpoint |
| Direct database access | Bypasses API-level validation entirely |
| Background job processing | Enters the system without HTTP request validation |
| Internal service call | Skips user-facing input sanitization |

## How to Apply After a Fix

1. Fix the root cause (the primary bug)
2. Identify every layer the bad data passed through
3. For each layer, ask: "If the upstream fix didn't exist, would this layer catch the problem?"
4. Add validation only where the answer is "no" and the layer reasonably should catch it
5. Don't over-validate — add guards where they prevent real failure modes, not hypothetical ones

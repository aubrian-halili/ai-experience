# Verification Discipline

## Iron Law

No completion claim without fresh terminal output as evidence.

This applies to:
- Marking any task/milestone as `completed`
- Any statement like "tests pass", "build succeeds", "feature works"
- Moving to the next milestone or phase

## What Counts as Evidence

| Claim | Required Evidence |
|-------|-------------------|
| Tests pass | Test runner output showing 0 failures in current message |
| Build succeeds | Build command output with exit code 0 |
| Feature works | Demonstration command output or test output |
| Bug fixed | Regression test red-green cycle output |

## Rationalization Prevention

| Shortcut | Why It Fails |
|----------|-------------|
| "Should work now" | "Should" is not evidence — run the command |
| "I just ran the tests" | If the output isn't in this message, re-run |
| "The code looks correct" | Code reading is not verification |
| "Same pattern as the working one" | Patterns can be applied incorrectly |
| "The file exists so it's wired" | Existence is Level 1; you haven't checked Level 3 |
| "I wrote it, I know it works" | The anti-pattern list exists because experienced devs write stubs too |
| "Tests pass so it's complete" | Passing tests verify behavior, not wiring or substance |
| "It's just a config change, no verification needed" | Config errors are silent failures; verify the runtime loads the value |

## The Gate Function

Before claiming ANY status (passes, works, fixed, complete, done):

1. **IDENTIFY** — What command proves this claim?
2. **RUN** — Execute the full command (fresh, in this session)
3. **READ** — Check full output and exit code
4. **VERIFY** — Does output actually confirm the claim?
   - If NO → state actual status with evidence
   - If YES → state claim WITH evidence
5. **CLAIM** — Only now make the statement

Skipping any step means the claim is unverified.

## Agent Delegation

| Claim | Required Evidence |
|-------|-------------------|
| Agent reports success | VCS diff shows expected changes; tests pass independently — agent's word is not evidence |
| About to commit/push/PR | Fresh test output in current message — not "just ran them" |

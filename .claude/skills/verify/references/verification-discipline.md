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
| "Should work now" / "The code looks correct" | Code reading is not verification — run the command |
| "The file exists so it's wired" | Existence is Level 1; you haven't checked Level 3 |
| "Tests pass so it's complete" | Passing tests verify behavior, not wiring or substance |
| "It's just a config change, no verification needed" | Config errors are silent failures; verify the runtime loads the value |

## Agent Delegation

| Claim | Required Evidence |
|-------|-------------------|
| Agent reports success | VCS diff shows expected changes; tests pass independently — agent's word is not evidence |
| About to commit/push/PR | Fresh test output in current message — not "just ran them" |

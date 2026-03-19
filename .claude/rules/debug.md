# Debugging

## Iron Laws

- **Reproduce first** — never hypothesize without seeing the failure
- **One hypothesis at a time** — changing multiple things obscures root cause
- **Analysis paralysis guard** — after reading 5+ files without a hypothesis, stop and regroup
- **Minimal fix** — change the least code possible; do not refactor during debugging
- **3+ fixes failed** — stop and question the architecture, not the implementation

## Process

1. **Reproduce** — confirm the failure is reproducible; record expected vs actual behavior
2. **Isolate** — trace backward from the failure site to find where behavior diverges
3. **Hypothesize** — form one testable hypothesis: "The bug occurs because [condition] at `file:line`"
4. **Fix** — apply the minimal fix; write/update a test that would have caught this
5. **Verify** — run original test + related tests; confirm no regressions

## Output Format

Present findings as: **Symptom → Root Cause → Fix → Verification**. Every claim references `file:line`.

# Debugging

## Iron Laws

- **Reproduce first** — never hypothesize without seeing the failure
- **One hypothesis at a time** — changing multiple things obscures root cause
- **Analysis paralysis guard** — after reading 5+ files without a hypothesis, stop and regroup
- **Minimal fix** — change the least code possible; do not refactor during debugging
- **3+ fixes failed** — stop and question the architecture, not the implementation

## Output Format

Present findings as: **Symptom → Root Cause → Fix → Verification**. Every claim references `file:line`.

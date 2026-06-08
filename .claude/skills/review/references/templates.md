# Review Response Templates

## Severity (shared)

- **Blocking** — must fix before merge (correctness, security, data loss)
- **Non-blocking** — should fix (design, clarity, maintainability)
- **Optional** — nice to have

Every finding references `file:line`. Use a `diff` block for concrete suggestions.

## Local Changes / Single Files

```markdown
## Review Summary

**Verdict**: Approve | Request Changes | Needs Discussion

### Blocking
1. **[Title]** — `file:line` — [problem and fix]

### Non-blocking
1. **[Title]** — `file:line` — [suggestion]

### Optional
- [Idea]
```

## Pull Request Review

```markdown
## Pull Request Review

**PR**: #[number] — [title]
**Author**: @[username]
**Base**: [base-branch] ← [head-branch]
**Files Changed**: [count] | **+[additions]** / **-[deletions]**

### Summary
[2-3 sentence summary of what this PR does and why]

### Impact
**Blast Radius**: [Low | Medium | High]

| File | Type | Risk | Key Changes |
|------|------|------|-------------|
| `src/api/users.ts` | Core Logic | Medium | New endpoint |

### Findings

#### Blocking
1. **[Title]** — `file:line` — [problem and fix]

#### Non-blocking
1. **[Title]** — `file:line` — [suggestion]

#### Optional
- [Idea]

### Testing
[Coverage added/missing — e.g., "Unit tests cover happy path; integration not tested."]

**Verdict**: Approve | Request Changes | Needs Discussion

### Follow-up
1. [Action item]
```

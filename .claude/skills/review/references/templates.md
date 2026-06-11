# Review Response Template

## Severity

- **Blocking** — must fix before merge (correctness, security, data loss)
- **Non-blocking** — should fix (design, clarity, maintainability)
- **Optional** — nice to have

Every finding references `file:line`. Use a `diff` block for concrete suggestions.

## Review Output

```markdown
## Review Summary

**Verdict**: Approve | Request Changes | Needs Discussion

### Impact
**Blast Radius**: [Low | Medium | High]

### Blocking
1. **[Title]** — `file:line` — [problem and fix]

### Non-blocking
1. **[Title]** — `file:line` — [suggestion]

### Optional
- [Idea]

### Testing
[Coverage added/missing — e.g., "Unit tests cover happy path; integration not tested."]
```

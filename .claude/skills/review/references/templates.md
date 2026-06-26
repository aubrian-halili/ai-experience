# Review Response Template

## Severity

- **Blocking** — must fix before merge
- **Non-blocking** — should fix
- **Optional** — nice to have

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

### Pattern Alignment
[From code-explorer + code-architect. For each unjustified divergence:]
1. **[Title]** — divergent `file:line` vs sibling `file:line` — [how it departs] → [code-architect realignment suggestion]
[If none: "No unjustified divergence from existing siblings."]

### Testing
[Coverage added/missing — e.g., "Unit tests cover happy path; integration not tested."]
```

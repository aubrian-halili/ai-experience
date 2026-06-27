# Templates

Single source for severity vocabulary, the review output block, and the combined gate verdict.

## Severity

- **Blocking** — must fix before merge
- **Non-blocking** — should fix
- **Optional** — nice to have

Every finding cites `file:line` evidence.

## Review Output (`/review`, and the Quality section of `/gate`)

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

## Gate Verdict (`/gate`)

```markdown
## Gate Result — [PR #<n> "<title>" | feature <name>]

**Mode**: PR | Feature
**Requirements source**: PR description | .planning/STATE.md | user-provided

### Completeness — /verify
**Result**: PASS | PARTIAL | FAIL | SKIP
- [Existence/Substance/Wiring findings with `file:line`]

### Quality — /review
**Verdict**: Approve | Request Changes | Needs Discussion
- **Blocking**: [findings with `file:line`, or "none"]
- **Non-blocking**: [findings with `file:line`, or "none"]
- **Optional**: [ideas, or "none"]

---

## Gate verdict: READY | BLOCKED

[If READY: state that completeness and quality both passed.]
[If BLOCKED: numbered list of blockers — each the failing dimension + `file:line` + what to fix.]
```

# Gate Verdict Template

Severity vocabulary is shared with `/review`: **Blocking** (correctness, security, data loss) · **Non-blocking** (design, clarity, maintainability) · **Optional**. Every finding references `file:line`.

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

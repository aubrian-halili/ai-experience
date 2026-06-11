# Gate Verdict Template

Severity vocabulary and the `file:line` evidence rule are defined in `/review`'s `references/templates.md` (Severity section) — reuse them here.

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

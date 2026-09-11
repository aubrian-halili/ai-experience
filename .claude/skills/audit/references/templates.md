# Templates

## Audit Output (`/audit`)

```markdown
## Double-check — [the question or claim audited]

**Answer type**: Enumeration/count | Factual lookup | Explanation | Change/edit
**Independent route**: [how the re-derivation reached its answer — the search vectors used]
**Scope rule applied**: [the definition the count/claim holds under]

### Assertions
| # | Assertion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [claim] | Confirmed / Corrected / Unverified | `file:line` |

### Corrections
1. **[What was wrong]** — original said [X], actual is [Y] — `file:line`.
[If none: "No corrections — every assertion re-derived independently."]

### Unverified
- [What could not be confirmed, and why — failed tool, inaccessible source, genuine ambiguity.]
[If none: "Nothing unverified."]

---

## Verdict: CONFIRMED | CORRECTED | UNVERIFIED

[CONFIRMED: what was re-derived and by what independent route.]
[CORRECTED: the corrected answer in full — not a diff against the previous one.]
[UNVERIFIED: what blocks confirmation, and what the user can do about it.]
```

## Verdict vocabulary

- **CONFIRMED** — every assertion re-derived independently, closure claims included.
- **CORRECTED** — at least one assertion was wrong; the corrected answer is stated in full.
- **UNVERIFIED** — a tool failed, a source was unreachable, or the scope is genuinely ambiguous.
  Never collapse this into CONFIRMED.

# Templates

Single source for severity vocabulary, the review output block, and the combined gate verdict.

## Severity

**Blocking** · **Non-blocking** · **Optional** — every finding cites `file:line` evidence and carries
the assessment from **What every pass returns** in `passes.md` (impact, likelihood, why in this
change, cost of the fix, confidence). Severity follows from **impact × likelihood**, not from the
agent's label:

- **Blocking** — a likely, concrete harm, a correctness bug, or a broken written repo rule.
- **Non-blocking** — a concrete harm that is unlikely, or minor when it occurs.
- **Optional** — a concrete but small improvement.

Treat an agent's Critical/High/Medium/Low as input to that judgment, not as the answer. Do not raise
severity because a fix is easy, nor lower it because a fix is hard. A finding with no concrete impact
is dropped, not given a lower severity.

## Finding

Every Blocking, Non-blocking, and Optional entry below uses this shape:

```markdown
1. **[Title]** — `file:line` — [problem] → [fix]
   - Impact: [scenario, inputs/state, who notices]
   - Likelihood: [how often, under what conditions; evidence]
   - Why in this change: introduced | worsened | adjacent (context only)
   - Cost of the fix: [doc/test/type edit | adds mechanism: …]; [written rule it must follow, or "none found"]
   - Confidence: [verified … / assumed …]
```

## Review Output (`/review`)

```markdown
## Review Summary

**Verdict**: Approve | Request Changes | Needs Discussion

### Impact
**Blast Radius**: [Low | Medium | High]

### Blocking
[Findings, in the Finding shape]

### Non-blocking
[Findings, in the Finding shape]

### Optional
[Findings, in the Finding shape]

### Pattern Alignment
[From code-explorer + code-architect. For each unjustified divergence:]
1. **[Title]** — divergent `file:line` vs sibling `file:line` — [how it departs] → [code-architect realignment suggestion] — Impact: [what the divergence causes]
[If none: "No unjustified divergence from existing siblings."]

### Comment Noise
[Comments added by this change that the code already says. Each: `file:line` — quoted comment → delete | shorter replacement — Impact: [what it causes].]
[If none: "No redundant comments introduced."]

### Testing
[Coverage added/missing — e.g., "Unit tests cover happy path; integration not tested."]
```

## Gate Verdict (`/gate`)

```markdown
## Gate Result — [PR #<n> "<title>" | feature <name>]

**Mode**: PR | Feature
**Requirements source**: PR description | .planning/STATE.md | user-provided
**Run**: first | re-run #<k> — **Gated at**: `<HEAD SHA>`
**Sweep**: [re-runs only — the one-line pre-regate sweep report]
**Passes skipped**: [re-runs: each skipped pass + reason; database-explorer skip on any run; or "none"]

### Completeness — /verify
**Result**: PASS | PARTIAL | FAIL | SKIP
- [Existence/Substance/Wiring findings with `file:line`]

### Quality — /review
**Verdict**: Approve | Request Changes | Needs Discussion
- **Blocking**: [findings in the Finding shape, or "none"]

### Context
[One line each for findings dropped by provenance that still matter for go-live, or "none".]

---

## Gate verdict: READY | BLOCKED

READY = completeness PASS and no Blocking findings. Non-blocking and Optional findings never block
and never require another gate run.

[If READY: state that completeness and quality both passed.]
[If BLOCKED: numbered list of blockers — each the failing dimension + `file:line` + what to fix.]

### Since the last run
- **Fixed**: [findings from the previous run that are now resolved, or "first run"]
- **Follow-up**: [findings sent to follow-up + where each was recorded (ADR, INDEX, ticket), or "none"]

### Triage — Non-blocking and Optional

| Finding | Impact | Likelihood | Why in this change | Cost of the fix | Recommendation |
|---------|--------|------------|--------------------|-----------------|----------------|
| `file:line` — [title] | … | … | … | … | **Fix now** \| **Follow-up** \| **Ignore** — [one sentence on the impact] |

[If none: "No Non-blocking or Optional findings."] You decide which to act on; there is no "apply all".
```

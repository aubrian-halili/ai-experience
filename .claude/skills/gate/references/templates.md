# Templates

Single source for severity vocabulary, the review output block, and the combined gate verdict.

## Severity

**Blocking** · **Non-blocking** · **Optional** — every finding cites `file:line` and uses the
Finding shape below. Severity follows from **impact × likelihood**, not from the agent's label:

- **Blocking** — a likely, concrete harm, a correctness bug, or a broken written repo rule.
- **Non-blocking** — a concrete harm that is unlikely, or minor when it occurs.
- **Optional** — a concrete but small improvement.

Treat an agent's Critical/High/Medium/Low as input to that judgment, not as the answer.

## Finding

Every Non-blocking and Optional entry below uses this shape. A Blocking entry uses the extended
**Blocking finding** shape that follows:

```markdown
1. **[Title]** — `file:line` — [problem] → [fix]
   - Impact: [scenario, inputs/state, who notices]
   - Likelihood: [how often, under what conditions; evidence]
   - Why in this change: introduced | worsened | adjacent (context only)
   - Cost of the fix: [doc/test/type edit | adds mechanism: …]; [written rule it must follow, or "none found"]
   - Confidence: [verified … / assumed …]
```

## Blocking finding (`/review` and `/gate`)

A Blocking entry in the review output or the gate verdict must let the reader understand the defect
and apply the fix without re-reading the diff or the pass's report. The dispatcher writes it **after
reading the cited code itself**, in its own words — never paste the pass's wording. If the failure path does not hold
up when traced in the code, the finding is not Blocking.

~~~markdown
1. **[Title]** — `file:line` — [one plain sentence: what goes wrong, and for whom]
   - **What's wrong**: [2–4 plain sentences: what the code does now, what it should do, and why the
     difference matters. Name the requirement or written repo rule it breaks, if any.]
   - **Current code** (`file:start-end`):
     ```<lang>
     [the smallest excerpt that shows the defect — at most ~15 lines]
     ```
   - **How it fails**:
     1. [starting input or state]
     2. [each step through the code, with `file:line`]
     3. [the observable result, and who notices]
   - Impact: [scenario, inputs/state, who notices]
   - Likelihood: [how often, under what conditions; evidence]
   - Why in this change: introduced | worsened | adjacent (context only)
   - **Fix**: [what to change and where, and why this is the smallest scope that removes the defect]
     ```diff
     [sketch of the change — at most ~15 lines; for a fix spanning files, a numbered step list instead]
     ```
   - Cost of the fix: [doc/test/type edit | adds mechanism: …]; [written rule it must follow, or "none found"]
   - **Verify the fix**: [the test to add or command to run that fails today and passes after — file and case name]
   - **Alternatives**: [only when there is a real choice between fixes: each option with its trade-off, and which to prefer; otherwise omit]
   - Confidence: [verified … / assumed …]
~~~

## Review Output (`/review`)

**Verdict** rule: **Request Changes** = any Blocking finding. **Needs Discussion** = no Blocking
finding, but one hinges on a requirement or design question only the user can settle. Otherwise
**Approve**.

```markdown
## Review Summary

**Verdict**: Approve | Request Changes | Needs Discussion

### Impact
**Blast Radius**: [Low | Medium | High]

### Blocking
[Findings, in the Blocking finding shape]

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
**Passes skipped / failed**: [re-runs: each skipped pass + reason; database-explorer skip on any run; any pass that failed to return a report; or "none"]

### Completeness — /verify
**Result**: PASS | PARTIAL | FAIL | SKIP
- [Existence/Substance/Wiring findings with `file:line`]

### Quality — /review
**Verdict**: Approve | Request Changes | Needs Discussion
- **Blocking**: [findings in the Blocking finding shape, or "none"]

### Context
[One line each for findings dropped by provenance that still matter for go-live, or "none".]

---

## Gate verdict: READY | BLOCKED

READY = completeness PASS and no Blocking findings. Non-blocking and Optional findings never block
and never require another gate run.

[If READY: state that completeness and quality both passed.]
[If BLOCKED: numbered list of blockers — each the failing dimension + `file:line` + what to fix in
one line, pointing to its full Blocking finding above (e.g. "see Blocking #2").]

### Since the last run
- **Fixed**: [findings from the previous run that are now resolved, or "first run"]
- **Follow-up**: [findings sent to follow-up + where each was recorded (ADR, INDEX, ticket), or "none"]

### Triage — Non-blocking and Optional

| Finding | Impact | Likelihood | Why in this change | Cost of the fix | Recommendation |
|---------|--------|------------|--------------------|-----------------|----------------|
| `file:line` — [title] | … | … | … | … | **Fix now** \| **Follow-up** \| **Ignore** — [one sentence on the impact] |

[If none: "No Non-blocking or Optional findings."] You decide which to act on; there is no "apply all".
```

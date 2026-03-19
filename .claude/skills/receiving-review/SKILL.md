---
name: receiving-review
description: >-
  User asks to "address review comments", "fix the PR feedback",
  "implement reviewer suggestions", or wants to process review feedback on a PR.
  Not for: giving a code review (use /review), creating a PR (use /pr).
argument-hint: "[PR number, URL, or 'latest']"
disable-model-invocation: true
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, Write, Edit, Agent
---

**Current branch:** !`git branch --show-current`
**Open PR:** !`gh pr view --json number,url,title --jq '"#\(.number) \(.title) — \(.url)"' 2>/dev/null || echo "No open PR on this branch"`

Process, evaluate, and implement code review feedback with technical rigor.

## Review Response Philosophy

- **Actions over words** — demonstrate understanding through code, not performative agreement
- **Verify before implementing** — check reviewer suggestions against codebase reality before acting
- **Clarify all before implementing any** — partial understanding leads to wrong implementations
- **Technical pushback is professional** — disagree with evidence when suggestions are wrong for this codebase
- **YAGNI discipline** — grep for actual usage before implementing "proper" features a reviewer suggests

## Iron Laws

> - NO performative agreement — no "great point!", "you're absolutely right!", no gratitude expressions in PR comments
> - NO implementation before ALL unclear items are clarified
> - NO suggested addition without checking if it's actually used/needed in the codebase
> - ALWAYS verify a suggestion against the actual code before implementing it

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "The reviewer is probably right, just do it" | Reviewers lack full context; verify their assumptions against the code |
| "I'll figure out what they mean as I go" | Ambiguous feedback implemented partially creates more review rounds |
| "Adding this won't hurt" | Unnecessary additions are maintenance burden; check YAGNI first |
| "I should be agreeable to move the PR forward" | Incorrect implementations waste more time than a clarifying question |

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| PR number (e.g., `123`, `#123`) | Address feedback on specific PR | Fetch PR comments, full process |
| PR URL | Address feedback on specific PR | Extract PR number, full process |
| `latest` or (none) | Address feedback on current branch's PR | Detect PR from branch, full process |
| Specific comment quote | Address single piece of feedback | Targeted single-comment workflow |

## Process

### 0. Pre-flight

- Resolve PR number from `$ARGUMENTS` or detect from current branch via `gh pr view --json number`
- Verify PR exists and is open: `gh pr view --json state --jq '.state'`
- Verify `gh` is authenticated: `gh auth status`

**Stop conditions:**
- No PR found for current branch → report; suggest creating PR with `/pr` first
- PR is closed or merged → report state and stop
- `gh` not authenticated → provide `gh auth login` instructions and stop
- No review comments found → report "no pending review comments"

### 1. Gather Feedback

Fetch all review comments and organize them:

```bash
# Get PR number from branch if not provided
PR_NUMBER=$(gh pr view --json number --jq '.number')

# Fetch all review comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments --paginate
gh pr view $PR_NUMBER --json reviews,comments
```

Categorize each comment:
- **Actionable request** — clear change requested (fix, rename, refactor, add test)
- **Question** — reviewer asking for clarification (respond, don't change code)
- **Suggestion** — optional improvement (evaluate before implementing)
- **Nitpick** — minor style/preference (evaluate against project conventions)
- **Approval note** — positive feedback (no action needed)

### 2. Classify and Prioritize

Sort feedback items by implementation order:

| Priority | Category | Action |
|----------|----------|--------|
| **1 — Blocking** | Security issues, correctness bugs, breaking changes | Must fix before merge |
| **2 — Required** | Reviewer-requested changes marked as "request changes" | Fix to unblock approval |
| **3 — Quick wins** | Simple renames, typo fixes, comment updates | Batch and fix together |
| **4 — Complex** | Architectural suggestions, refactors, new abstractions | Evaluate carefully |
| **5 — Defer** | Out-of-scope improvements, future enhancements | Acknowledge, don't implement |

### 3. Clarify Before Implementing

**CRITICAL — DO NOT SKIP this step.**

Before implementing ANY changes, identify ALL unclear items:

- Ambiguous phrasing — "this could be cleaner" (how specifically?)
- Assumed context — reviewer references something not visible in the diff
- Contradictory feedback — two comments suggest opposite approaches
- Scope uncertainty — unclear if the suggestion is a must-fix or nice-to-have

Present all unclear items to the user in a single organized list. Wait for answers before proceeding.

If the feedback source is a GitHub PR, draft clarifying questions as thread replies (not top-level comments) for user approval before posting.

### 4. Verify Suggestions Against Codebase

For each actionable suggestion, verify it before implementing:

**YAGNI check:**
```bash
# Before adding a suggested abstraction/interface/pattern, check if it's used
grep -r "SuggestedThing" --include="*.ts" --include="*.tsx" src/
```
If the suggested addition has zero consumers → push back with evidence.

**Correctness check:**
- Read the actual code the reviewer is commenting on
- Check if the reviewer's assumption about behavior is correct
- Verify the suggested fix doesn't break other callers/tests

**Convention check:**
- Does the suggestion align with existing codebase patterns?
- Check CLAUDE.md, linter config, and surrounding code for precedent

**Report findings to the user:**
- Suggestions that are correct and should be implemented
- Suggestions that are incorrect (with evidence) — draft pushback response
- Suggestions that are unnecessary (YAGNI) — draft explanation

### 5. Implement Changes

After user approval of the plan from step 4:

**Implementation order:** Blocking → Required → Quick wins → Complex (approved only)

For each change:
1. Make the code change
2. Verify the change doesn't break existing tests
3. Draft a thread reply explaining what was done (for user to post)

**Thread reply format** (concise, action-focused):
- What was changed and why (1-2 sentences max)
- If pushing back: technical reasoning with file/line references
- No performative language — no "thanks for catching this", no "great suggestion"

### 6. Reply to Review Threads

After implementing changes, prepare GitHub thread replies for user approval.

**Reply mechanics:**
```bash
# Reply to a specific review comment thread
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  -f body="<reply text>"
```

**Reply guidelines:**
- Reply in the existing thread, never as a top-level PR comment
- One reply per thread — batch related changes into a single response
- Lead with what was done: "Fixed — renamed to `calculateTotal` and updated callers in `OrderService`"
- For pushback: "Keeping as-is — `FooInterface` has no other implementors (grep confirms), so the abstraction adds complexity without benefit"
- For deferred items: "Tracked as follow-up — this is out of scope for the current PR but worth addressing"

**Always present all draft replies to the user before posting.** Never post to GitHub without explicit approval.

### 7. Push and Verify

After all changes are implemented:

```bash
# Verify tests still pass (if applicable)
# Push changes
git push

# Verify PR state
gh pr view $PR_NUMBER --json state,reviewDecision,statusCheckRollup
```

Report to the user: changes made, replies posted, remaining items (if any), and PR state.

## Output Principles

- **Action-first communication** — lead with what was done, not what was discussed
- **Evidence-based pushback** — every disagreement includes file paths, grep results, or test output
- **Batch presentation** — show all planned changes and draft replies together for single approval
- **No performative language** — in PR comments, communicate through actions and technical reasoning only

## Error Handling

| Scenario | Response |
|----------|----------|
| No PR found for current branch | Report; suggest creating PR with `/pr` first |
| No review comments found | Report "no pending review comments"; suggest requesting review |
| `gh` not authenticated | Provide `gh auth login` instructions and stop |
| PR is closed or merged | Report state and stop |
| Reviewer comment references deleted code | Note the staleness, ask user how to proceed |
| Conflicting reviewer feedback | Surface the contradiction, ask user to decide |
| Too many comments (>20) | Prioritize by blocking/required, batch quick wins, defer complex items |

Never silently skip feedback items or post replies without user approval.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Giving a code review (not receiving one) |
| `/pr` | Creating a pull request |
| `/commit` | Committing changes after addressing feedback |
| `/review --refactor` | Reviewer suggests deep refactoring beyond PR scope |
| `/finish` | Wrap up branch after all review feedback is addressed |

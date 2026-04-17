---
name: receiving-review
description: >-
  User asks to "address review comments", "fix the PR feedback",
  "implement reviewer suggestions", or wants to process review feedback on a PR.
  Not for: giving a code review (use /review), creating a PR (use /pr).
argument-hint: "[PR number, URL, or 'latest']"
disable-model-invocation: true
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, Write, Edit, Agent, Skill
---

**Current branch:** !`git branch --show-current`
**Open PR:** !`gh pr view --json number,url,title --template '#{{.number}} {{.title}} — {{.url}}'`

Process, evaluate, and implement code review feedback with technical rigor.

## Iron Laws

> - YAGNI discipline — grep for actual usage before implementing "proper" features a reviewer suggests

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| PR number or URL | Address feedback on specific PR | Fetch PR comments, full process |
| `latest` or (none) | Address feedback on current branch's PR | Detect PR from branch, full process |
| Specific comment quote | Address single piece of feedback | Targeted single-comment workflow |

## Process

### 0. Pre-flight

- Resolve PR number, state, and head branch in a single call: `gh pr view --json number,state,headRefName`
  - Use `$ARGUMENTS` to target a specific PR number/URL if provided, otherwise detect from current branch
- Verify PR is open: check `state` from the call above
- **Branch verification** (when PR number/URL was provided via arguments):
  1. Get current branch: `git branch --show-current`
  2. Compare against `headRefName` from the pre-flight call above
  3. If they match → proceed
  4. If mismatch:
     - Check for dirty working tree: `git status --porcelain`
     - If dirty → **stop**: "Working tree has uncommitted changes. Stash or commit before switching branches."
     - If clean → ask user for confirmation, then switch: `gh pr checkout $PR_NUMBER`

### 1. Gather Feedback

Fetch all review comments and organize them:

```bash
# Fetch inline review comments with diff context (file path, diff position, in_reply_to_id)
# These details are not exposed by `gh pr view`
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments --paginate

# Fetch top-level review bodies and general PR comments (not available via the comments API above)
gh pr view $PR_NUMBER --json reviews,comments
```

Note which review threads are already resolved. Focus on **unresolved threads** first.

### 2. Clarify Before Implementing

If the feedback source is a GitHub PR, draft clarifying questions for user approval before posting.

### 3. Verify Suggestions Against Codebase

For each actionable suggestion, verify it before implementing:

**YAGNI check:**
```bash
# Before adding a suggested abstraction/interface/pattern, check if it's actually consumed
# Replace <SuggestedName> with the actual interface, class, or pattern name being suggested
grep -r "<SuggestedName>" --include="*.ts" --include="*.tsx" src/
```
If the suggested addition has zero consumers → push back with evidence.

### 4. Implement Changes

### 5. Reply to Review Threads

After implementing changes, prepare thread replies for user approval.

**Reply mechanics:**
```bash
# Reply to a specific review comment thread
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  -f body="<reply text>"
```

**Reply guidelines:**
- Reply in the existing thread, never as a top-level PR comment
- One reply per thread — batch related changes into a single response
- Examples: "Fixed — renamed to `calculateTotal` and updated callers in `OrderService`" / "Keeping as-is — `FooInterface` has no other implementors (grep confirms), so the abstraction adds complexity without benefit" / "Tracked as follow-up — out of scope for this PR"

### 6. Commit, Push, and Verify

After all changes are implemented and replies posted, commit and push, then verify PR state:

```bash
gh pr view $PR_NUMBER --json state,reviewDecision,statusCheckRollup
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Giving a code review (not receiving one) |
| `/pr` | Creating a pull request |
| `/feature` | Re-implementation needed for significant reviewer feedback |
| `/verify` | Re-verify after significant changes from review feedback |

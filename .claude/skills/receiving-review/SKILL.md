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
- **Branch verification** (when PR number/URL was provided via arguments): if `headRefName` ≠ current branch, refuse if working tree is dirty; otherwise confirm with user and switch with `gh pr checkout $PR_NUMBER`

### 1. Gather Feedback

Fetch all review comments and organize them:

```bash
# Fetch inline review comments with diff context (file path, diff position, in_reply_to_id)
# These details are not exposed by `gh pr view`
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments --paginate

# Fetch top-level review bodies and general PR comments (not available via the comments API above)
gh pr view $PR_NUMBER --json reviews,comments
```

### 2. Verify Before Implementing

**Triage each comment, then verify its factual claim against the codebase before changing anything.** Confirmed → implement; refuted → push back with the evidence (§3).

> Dispatch verification agents from **this (main) loop**, in **one message** so they run concurrently. A spawned agent cannot spawn its own subagents — if you are one (no `Agent` tool), report that and verify inline instead.

| Comment makes a claim about… | Verify with | Concrete question to pass |
|------------------------------|-------------|---------------------------|
| **Persisted data** — schema, column type/nullability, indexes, soft-delete/filtering, migrations | `database-explorer` | "Does `r_client_score` have an `isactive` column, and how do sibling repositories filter it?" |
| **Existing patterns** — "this doesn't match how we do X elsewhere" | `code-explorer` | "Find the sibling the reviewer cites and confirm the new code actually diverges." |
| **Security / correctness / perf** — injection, auth, N+1, error handling | `security-scanner` / `code-quality-reviewer` | The cited `file:line` and the specific risk claimed. |
| **Unneeded abstraction (YAGNI)** | grep — no agent | `grep -r "<SuggestedName>" --include="*.ts" --include="*.tsx" src/` — zero consumers → push back. |

**Scope check** — before accepting blame, confirm the comment targets code *this PR introduced*: `git blame -L <start>,<end> <file>`. If the line is pre-existing, note it as out of scope rather than fixing it here.

### 3. Reply to Review Threads

Draft replies for user approval before posting.

**Reply mechanics:**
```bash
# Reply to a specific review comment thread
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  -f body="<reply text>"
```

**Reply guidelines:**
- One reply per thread — batch related changes into a single response
- Back every push-back with the §2 evidence: "Keeping as-is — `FooInterface` has no other implementors (grep confirms), so the abstraction adds complexity without benefit" / "Confirmed — `isactive` exists and the sibling repo filters on it (database-explorer), so I added the filter" / "Out of scope — `git blame` shows this line predates the PR; tracking as a follow-up"

### 4. Verify PR state after pushing

```bash
gh pr view $PR_NUMBER --json state,reviewDecision,statusCheckRollup
```

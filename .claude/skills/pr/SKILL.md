---
name: pr
description: >-
  User asks to "create a PR", "open a pull request", "push and create PR",
  or mentions "pull request" in context of creating one.
  Not for: reviewing an existing PR (use /review).
argument-hint: "[optional: --major, --fe, --ready, target branch, or PR title]"
allowed-tools: Bash(git branch *, git log *, git diff *, git show *, git status *, git rev-list *, git push *, git fetch *, git remote *, gh repo *, gh pr *, acli *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:** !`git log --oneline -5`

## Process

### 1. Pre-flight Checks

Parse `$ARGUMENTS` for flags (`--major`, `--fe`, `--ready`, `--base`, `--label`), then stop if any of these apply:

- On `main`/`master` → Cannot create PR from default branch

### 2. Prepare Body

**Body generation** — select template based on flags:

| Flags          | Template                                 |
|----------------|------------------------------------------|
| (none)         | @references/minor-template.md            |
| `--major`      | @references/major-template.md            |
| `--fe`         | @references/frontend-minor-template.md   |
| `--fe --major` | @references/frontend-major-template.md   |

**CRITICAL: The PR body MUST be constructed from the selected template file.** Read the template file and include **every section, checkbox, and line** — do not omit or summarize any part of the template. Fill in dynamic sections from commit history and check off only the items that apply.

Indicate which template was used (minor/major, and `(frontend)` when `--fe` is active) so the user can override with `--major` or `--fe` if needed.

### 3. Push & Create PR

Push the branch and create the PR as a **draft by default** — omit `--draft` only if `--ready` was passed.

**Jira integration (optional):** After PR creation, if a Jira ticket ID was detected and `acli` is available, offer to transition the ticket status to "In Review" using `acli jira workitem transition --key <ISSUE_KEY> --status "In Review"`. Always confirm with the user before changing ticket status.

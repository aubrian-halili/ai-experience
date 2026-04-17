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

### 1. Pre-flight
Parse `$ARGUMENTS` for `--major`, `--fe`, `--ready`. Refuse if current branch is `main`/`master`.

### 2. Prepare Body
Select template by flags:

| Flags          | Template                                 |
|----------------|------------------------------------------|
| (none)         | @references/minor-template.md            |
| `--major`      | @references/major-template.md            |
| `--fe`         | @references/frontend-minor-template.md   |
| `--fe --major` | @references/frontend-major-template.md   |

Include **every section, checkbox, and line** of the selected template verbatim — do not summarize. Fill dynamic sections from commit history; tick only items that apply.

### 3. Push & Create PR
Push branch and create PR as **draft** unless `--ready` is passed.

**Jira (optional):** If a Jira ID is detected and `acli` is available, offer to run `acli jira workitem transition --key <ISSUE_KEY> --status "In Review"`.

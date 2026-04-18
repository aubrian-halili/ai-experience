---
name: qred-repo
description: >-
  User asks to "browse a Qred repo", "search code across Qred repos", "list Qred repos",
  "find <term> in <repo>", "view PR/issue in <repo>", or "read a file from a Qred repo".
  Read-only: scoped to the Qred GitHub org; refuses mutating gh subcommands (merge, close, edit, delete, transfer, archive).
  Not for: code review (use /review); not for: DB exploration (use /backoffice-database).
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
disable-model-invocation: true
allowed-tools: Bash(gh *)
---

Layered repository exploration and code searching across the Qred GitHub organization.

## Guardrails

**Read-only and informational operations only.** Refuse any mutating `gh` subcommand (write, delete, close, merge, edit, transfer, archive) and explain why.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) or `repos` | List repositories | Direct |
| `prs <repo>` or `pr <repo> #<n>` | List or view PRs | Direct |
| `issues <repo>` or `issue <repo> #<n>` | List or view issues | Direct |
| Starts with `gh` | Pass-through command | Direct |
| Repo name (e.g., `qred-mcp-proxy`) | Orient to repo | Layered; enter at Layer 1 |
| `tree <repo>` or `<repo>/<path>/` | Navigate structure | Layered; enter at Layer 2 |
| Search term (no path separators) | Search code across org | Layered; enter at Layer 3 |
| `<term> in <repo>` | Search code in repo | Layered; enter at Layer 3 |
| `<repo>/<file-path>` | Read file contents | Layered; enter at Layer 4 |

## Process

### Direct Operations

- **List repos:** `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt`
- **List PRs/issues:** `gh pr list` / `gh issue list` with relevant `--json` fields
- **View PR/issue:** `gh pr view` / `gh issue view` with relevant `--json` fields

### Layered Exploration Workflow

#### Layer 1: Orient

Run `gh repo view Qred/<repo>` to get README and metadata.

#### Layer 2: Navigate

Run `gh api repos/Qred/<repo>/contents/<path>` to get directory listing and present as a tree.

#### Layer 3: Search

- Org-wide: `gh search code --owner Qred "<term>" --limit 30 --json path,repository,textMatches`
- Repo-scoped: `gh search code --repo Qred/<repo> "<term>" --limit 30 --json path,repository,textMatches`

#### Layer 4: Read

Run `gh api repos/Qred/<repo>/contents/<path>` to get file content.

**300-line threshold:** if a file exceeds 300 lines, show the first 100 lines and ask before showing more.

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |
| `/confluence` | Reference design docs or specs related to the repository |

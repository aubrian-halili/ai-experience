---
name: qred-repo
description: >-
  User asks to "browse a repo", "search across repos", "list Qred repos",
  or wants to navigate the Qred GitHub organization's repositories.
  Not for: querying the database (use /backoffice-database).
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
disable-model-invocation: true
allowed-tools: Bash(gh *)
---

Layered repository exploration and code searching across the Qred GitHub organization — orient first, then navigate, search, and read only what is relevant.

## Guardrails

**Read-only and informational operations only.** The following `gh` subcommands are forbidden — refuse if requested and explain why:

- `gh repo delete`, `gh repo archive`, `gh repo rename`, `gh repo transfer`
- `gh pr close`, `gh pr merge`, `gh pr edit` (modifying state)
- `gh issue close`, `gh issue delete`
- Any command with `--confirm`, `--yes`, or `-y` flags on destructive operations

For pass-through commands (input starting with `gh`), validate against this blocklist before executing. If the command matches a forbidden pattern, refuse: "That command modifies repository state — use the GitHub UI or CLI directly for this action."

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) or `repos` | List repositories | Direct; execute immediately |
| `prs <repo>` or `pr <repo> #<n>` | List or view PRs | Direct; execute immediately |
| `issues <repo>` or `issue <repo> #<n>` | List or view issues | Direct; execute immediately |
| Starts with `gh` | Pass-through command | Direct; execute as-is |
| Repo name (e.g., `qred-mcp-proxy`) | Orient to repo | Layered; enter at Layer 1 |
| `tree <repo>` or `<repo>/<path>/` | Navigate structure | Layered; enter at Layer 2 |
| Search term (no path separators) | Search code across org | Layered; enter at Layer 3 |
| `<term> in <repo>` | Search code in repo | Layered; enter at Layer 3 |
| `<repo>/<file-path>` | Read file contents | Layered; enter at Layer 4 |

## Process

### 1. Pre-flight

1. Run `gh auth status`; on failure, see Error Handling below.

### 2. Execute Direct Operations

- **List repos:** `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt`
- **List PRs/issues:** add `--json number,title,state,author,updatedAt`
- **View PR/issue:** add `--json number,title,body,state,author`

### 3. Layered Exploration Workflow

#### Layer 1: Orient

1. Run `gh repo view Qred/<repo>` to get README and metadata

**Guardrails:** Never skip this layer when exploring a repo for the first time.

#### Layer 2: Navigate

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get directory listing
2. Present as an indented tree view:
   ```
   Qred/<repo>
   +-- README.md
   +-- src/
   |   +-- index.ts
   |   +-- config/
   |   |   +-- database.ts
   |   +-- routes/
   |       +-- (...)
   +-- tests/
       +-- (...)
   ```
   Use `+--` for entries, `|` for continuation lines, `(...)` for unexplored/truncated directories.

**Guardrails:** Max 3 directory levels deep. Max 30 entries per directory — if exceeded, show first 30 and note the remainder.

#### Layer 3: Search

1. Run `gh search code --owner Qred "<term>" --limit 30 --json path,repository,textMatches`
2. For repo-scoped search: `gh search code --repo Qred/<repo> "<term>" --limit 30 --json path,repository,textMatches`

**Result presentation:**

- Present matching files in `repo/path:line` format
- **Truncation block** (only when results = limit) — Show a multi-line refinement block:
  ```
  > Showing 30 results (limit reached) — results may be incomplete.
  >
  > Refine your search:
  > - Narrow to a repo: `/qred-repo <term> in <repo-name>`
  > - Narrow to a path: `gh search code --repo Qred/<repo> "<term>" path:src/`
  > - Increase limit:   `gh search code --owner Qred "<term>" --limit 100`
  ```

**Guardrails:** Cap results at 30 (`--limit 30`) — if results hit the cap, always show the truncation block.

#### Layer 4: Read

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get file metadata and encoded content

**Guardrails:** **300-line threshold:** if a file exceeds 300 lines, show the first 100 lines and ask before showing more. Skip binary/generated/lock files (e.g., `package-lock.json`, `yarn.lock`, `.min.js`).

## Error Handling

| Scenario | Response |
|---|---|
| `gh auth status` fails | "Run `gh auth login` and ensure your account has access to the Qred organization." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |
| `/plan` | Plan implementation after exploring a repo |
| `/confluence` | Reference design docs or specs related to the repository |

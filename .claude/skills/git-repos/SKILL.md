---
name: git-repos
description: >-
  User asks to "browse an org repo", "search code across org repos", "list org repos",
  "find <term> in <repo>", "view PR/issue in <repo>", or "read a file from an org repo".
  Read-only: scoped to a single GitHub org (resolved from $GITHUB_ORG or the user's org membership); refuses mutating gh subcommands (merge, close, edit, delete, transfer, archive).
  Not for: code review (use /review); not for: DB exploration (use /backoffice-database).
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
disable-model-invocation: true
allowed-tools: Bash(gh *, printenv GITHUB_ORG)
---

Layered repository exploration and code searching across a GitHub organization.

## Resolving the Org

`${GITHUB_ORG}` below is a placeholder for the GitHub organization to search. Resolve it once, at
the start of the session, and reuse the result:

1. Run `printenv GITHUB_ORG`. If it prints a value, use it. It is an optional override — leave it
   unset unless step 2 is ambiguous or unavailable.
2. Otherwise run `gh api user/orgs -q '.[].login'`. If exactly one org comes back, use it.
3. If several come back, or none do, ask which org to search — never guess, and never fall back to
   the current repository's owner (this repo may be personal rather than org-owned).

> **Planning-time research?** For grounding a `/plan` in how sibling repos solve a problem, the `git-repos-explorer` agent runs this same read-only search workflow non-interactively and returns a structured Essential References report. This skill is for interactive, ad-hoc browsing.

## Guardrails

**Read-only and informational operations only.** Refuse any mutating `gh` subcommand (write, delete, close, merge, edit, transfer, archive) and explain why.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) or `repos` | List repositories | Direct |
| `prs <repo>` or `pr <repo> #<n>` | List or view PRs | Direct |
| `issues <repo>` or `issue <repo> #<n>` | List or view issues | Direct |
| Starts with `gh` | Pass-through command | Direct |
| Repo name (e.g., `<repo>`) | Orient to repo | Layered; enter at Layer 1 |
| `tree <repo>` or `<repo>/<path>/` | Navigate structure | Layered; enter at Layer 2 |
| Search term (no path separators) | Search code across org | Layered; enter at Layer 3 |
| `<term> in <repo>` | Search code in repo | Layered; enter at Layer 3 |
| `<repo>/<file-path>` | Read file contents | Layered; enter at Layer 4 |

## Process

### Direct Operations

- **List repos:** `gh repo list ${GITHUB_ORG} --limit 30 --no-archived --json name,description,url,isArchived,pushedAt`
- **List PRs/issues:** `gh pr list` / `gh issue list` with relevant `--json` fields
- **View PR/issue:** `gh pr view` / `gh issue view` with relevant `--json` fields

### Layered Exploration Workflow

#### Layer 1: Orient

Run `gh repo view ${GITHUB_ORG}/<repo>` to get README and metadata.

#### Layer 2: Navigate

Run `gh api repos/${GITHUB_ORG}/<repo>/contents/<path>` to get directory listing and present as a tree.

#### Layer 3: Search

- Org-wide: `gh search code --owner ${GITHUB_ORG} "<term>" --limit 30 --json path,repository,textMatches`
- Repo-scoped: `gh search code --repo ${GITHUB_ORG}/<repo> "<term>" --limit 30 --json path,repository,textMatches`

#### Layer 4: Read

Run `gh api repos/${GITHUB_ORG}/<repo>/contents/<path>` to get file content.

**300-line threshold:** if a file exceeds 300 lines, show the first 100 lines and ask before showing more.

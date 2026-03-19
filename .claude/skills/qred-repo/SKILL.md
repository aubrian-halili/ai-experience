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

## Exploration Philosophy

- **Orient before reading** — understand a repo's purpose and structure before opening any code file
- **Search, don't scan** — use keyword search to find relevant code instead of reading files sequentially
- **Read the minimum** — only open files directly relevant to the question at hand
- **Documentation first** — always prefer README and docs over source code for understanding intent
- **Bound every operation** — limit search results, truncate large files, and cap directory depth

## Input Handling

Parse `$ARGUMENTS` to determine operation type — direct operations execute immediately, while exploration operations enter the layered workflow at the appropriate layer:

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

Parse `$ARGUMENTS` and validate GitHub CLI access:

1. Run `gh auth status` and confirm authentication is active
2. **Stop conditions:**
   - `gh` not installed → "Install with `brew install gh`, then `gh auth login`."
   - Not authenticated → "Run `gh auth login` to authenticate."
   - No Qred org access → "Ensure your GitHub account has access to the Qred organization."

### 2. Route Request

Route `$ARGUMENTS` using the Input Handling tables:
- **Direct operations** → proceed to step 3
- **Exploration operations** → proceed to step 4 at the specified entry layer

### 3. Execute Direct Operations

For all direct operations, use `--json` to get structured data:
- **List repos:** `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt` → present as table with name, description, last push date
- **List PRs/issues:** add `--json number,title,state,author,updatedAt` → present as table
- **View PR/issue:** add `--json number,title,body,state,author` → present title, author, state, and body

### 4. Layered Exploration Workflow

#### Layer 1: Orient

**Purpose:** Understand the repo before diving into code.

1. Run `gh repo view Qred/<repo>` to get README and metadata
2. Summarize the repo's purpose in 2-3 sentences
3. Present: language, stars, last push, and key README sections

**Guardrails:** Never skip this layer when exploring a repo for the first time. Do not auto-navigate into directories — let the user decide where to go next.

#### Layer 2: Navigate

**Purpose:** Understand directory structure without reading file contents.

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get directory listing
2. Present as an indented tree view (see `@references/formatting.md` for tree format)

**Guardrails:** Max 3 directory levels deep. Max 30 entries per directory — if exceeded, show first 30 and note the remainder. Only follow paths relevant to the user's question.

#### Layer 3: Search

**Purpose:** Find relevant code by keyword, not by browsing.

1. Run `gh search code --owner Qred "<term>" --limit 30 --json path,repository,textMatches`
2. For repo-scoped search: `gh search code --repo Qred/<repo> "<term>" --limit 30 --json path,repository,textMatches`

**Result presentation:**

- **Summary header** — Always show scope and count first: `Found N results in M repositories` (org-wide) or `Found N results in Qred/<repo>` (repo-scoped)
- **Repository breakdown** (org-wide only) — Group by repo with match counts before showing individual files:
  ```
  Found 23 results in 4 repositories:
  - qred-api (8 matches)
  - qred-mcp-proxy (7 matches)
  - qred-ui (5 matches)
  - backoffice-db (3 matches)
  ```
- **Individual matches** — Present matching files with `repo/path:line` format for editor-friendly references, with enough context to judge relevance before reading
- **Truncation block** (only when results = limit) — Show a multi-line refinement block:
  ```
  > Showing 30 results (limit reached) — results may be incomplete.
  >
  > Refine your search:
  > - Narrow to a repo: `/qred-repo <term> in <repo-name>`
  > - Narrow to a path: `gh search code --repo Qred/<repo> "<term>" path:src/`
  > - Increase limit:   `gh search code --owner Qred "<term>" --limit 100`
  ```

**Guardrails:** Cap results at 30 (`--limit 30`) — if results hit the cap, always show the truncation block. Do not auto-read all matching files — pick the 1-2 most relevant or let the user choose.

#### Layer 4: Read

**Purpose:** Read a single file's contents when you know it's relevant.

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get file metadata and encoded content
2. Decode the content: pipe through `jq -r '.content' | base64 -d`
3. Present file contents in a syntax-highlighted code block

**Guardrails:** One file at a time. **300-line threshold:** if a file exceeds 300 lines, show the first 100 lines and ask before showing more. Skip binary/generated/lock files (e.g., `package-lock.json`, `yarn.lock`, `.min.js`). Summarize the file's purpose before presenting raw content.

### 5. Verify

- Confirm the user's question has been answered by the layer(s) executed
- Note any repos, paths, or search terms that returned no results
- Suggest the natural next action using the follow-up table in `@references/formatting.md`

## Output Principles

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for listings, code blocks for file contents, tree format for directories (see `@references/formatting.md`)
- **Bounded output** — Truncate large results with clear indicators of what was omitted
- **Follow-up suggestions** — After each layer, suggest the natural next action (see `@references/formatting.md`)

## Error Handling

| Scenario | Response |
|---|---|
| `gh` not installed | "Install with `brew install gh`, then `gh auth login`." |
| Not authenticated | "Run `gh auth login` to authenticate." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |
| Repo not found | List repos with `/qred-repo` to find the correct name |
| File/path not found | List parent directory contents to help navigate |
| File too large (>300 lines) | Show first 100 lines and ask before showing more |
| No search results | Suggest alternative terms, broader scope, or different repo |
| API rate limit | "GitHub API rate limit exceeded. Wait a few minutes and retry." |

Never present results without context—always state what was searched, where, and what was omitted.

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |
| `/plan` | Plan implementation after exploring a repo |

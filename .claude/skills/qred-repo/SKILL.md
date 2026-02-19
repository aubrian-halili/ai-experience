---
name: qred-repo
description: Use when the user asks to "list repos", "show repo", "read file from repo", "search code", "find in org", "browse repo", "tree view", mentions "Qred repos", "GitHub org", "qred org", or needs layered repository exploration and code searching across the Qred GitHub organization.
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
allowed-tools: Bash(gh *)
---

# Qred Repository Navigator

Layered repository exploration and code searching across the Qred GitHub organization — orient first, then navigate, search, and read only what is relevant.

## When to Use

### This Skill Is For

- Listing repositories in the Qred GitHub organization
- Exploring repo structure through a layered orient → navigate → search → read workflow
- Browsing files and directories in a Qred repo (without cloning)
- Reading file contents from a Qred repo
- Searching code across repos in the Qred org
- Viewing pull requests and issues in Qred repos

### Use a Different Approach When

- Working with locally cloned files → use Glob, Read, Grep directly
- Deep end-to-end feature investigation → use `/explore`
- Reviewing code quality or PR changes → use `/review`
- Querying PostgreSQL databases → use `/backoffice-database`

## Exploration Philosophy

1. **Orient before reading** — Understand a repo's purpose and structure before opening any code file
2. **Search, don't scan** — Use keyword search to find relevant code instead of reading files sequentially
3. **Read the minimum** — Only open files directly relevant to the question at hand
4. **Documentation first** — Always prefer README and docs over source code for understanding intent
5. **Bound every operation** — Limit search results, truncate large files, and cap directory depth

## Process

### 0. Pre-flight Check

1. Run `gh auth status` and confirm authentication is active
2. Stop conditions:
   - `gh` not installed → "Install with `brew install gh`, then `gh auth login`."
   - Not authenticated → "Run `gh auth login` to authenticate."
   - No Qred org access → "Ensure your GitHub account has access to the Qred organization."

### 1. Determine Intent

Parse `$ARGUMENTS` to route to the correct operation type:

**Direct Operations** — Execute immediately, no layered workflow required:

| Argument Pattern | Intent | Command |
|---|---|---|
| (empty) or `repos` | List Qred org repos | `gh repo list Qred --limit 30` |
| `prs <repo>` or `pr list <repo>` | List PRs | `gh pr list -R Qred/<repo>` |
| `pr <repo> #<n>` | View specific PR | `gh pr view <n> -R Qred/<repo>` |
| `issues <repo>` | List issues | `gh issue list -R Qred/<repo>` |
| `issue <repo> #<n>` | View specific issue | `gh issue view <n> -R Qred/<repo>` |
| Starts with `gh` | Pass-through gh command | Execute as-is |

**Exploration Operations** — Enter the layered workflow at the appropriate layer:

| Argument Pattern | Intent | Entry Layer |
|---|---|---|
| Repo name only (e.g., `qred-mcp-proxy`) | View repo | Layer 1: Orient |
| `tree <repo>` or `tree <repo>/<path>` | Tree view | Layer 2: Navigate |
| `<repo>/` or `<repo>/<path>/` | Browse directory | Layer 2: Navigate |
| Search term (no path separators) | Search code across org | Layer 3: Search |
| `<term> in <repo>` | Search code in specific repo | Layer 3: Search |
| `<repo>/<file-path>` | Read file contents | Layer 4: Read |

### 2. Execute Direct Operations

For all direct operations, use `--json` to get structured data:
- **List repos:** `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt` → present as table with name, description, last push date
- **List PRs/issues:** add `--json number,title,state,author,updatedAt` → present as table
- **View PR/issue:** add `--json number,title,body,state,author` → present title, author, state, and body

### 3. Layered Exploration Workflow

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

**Result presentation order:**

3. **Summary header** — Always show scope and count first: `Found N results in M repositories` (org-wide) or `Found N results in Qred/<repo>` (repo-scoped)
4. **Repository breakdown** (org-wide only) — Group by repo with match counts before showing individual files:
   ```
   Found 23 results in 4 repositories:
   - qred-api (8 matches)
   - qred-mcp-proxy (7 matches)
   - qred-ui (5 matches)
   - backoffice-db (3 matches)
   ```
5. **Individual matches** — Present matching files with `repo/path:line` format for editor-friendly references, with enough context to judge relevance before reading
6. **Truncation block** (only when results = limit) — Show a multi-line refinement block:
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

### 4. Present Results

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for listings, code blocks for file contents, tree format for directories
- **Bounded output** — Truncate large results with clear indicators of what was omitted

For layer-specific follow-up suggestions, see `@references/formatting.md`.

## Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo` | List repositories in the Qred org |
| `/qred-repo qred-mcp-proxy` | Orient: view repo details, README, and summary |
| `/qred-repo OAuth` | Search: find "OAuth" across all Qred repos |
| `/qred-repo prs qred-mcp-proxy` | Direct: list open PRs in qred-mcp-proxy |

For the full list, see `@references/examples-and-errors.md`.

## Error Handling

Pre-flight errors are handled in Step 0. For all runtime errors (repo not found, file too large, rate limits, etc.), show the error and suggest the most helpful next action. See `@references/examples-and-errors.md` for the full error handling table.

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/explore` | Deep end-to-end investigation of locally cloned code |
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |

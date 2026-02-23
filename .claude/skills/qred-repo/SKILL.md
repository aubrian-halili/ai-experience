---
name: qred-repo
description: Use when the user asks to "list repos", "show repo", "read file from repo", "search code", "find in org", "browse repo", "tree view", mentions "Qred repos", "GitHub org", "qred org", or needs layered repository exploration and code searching across the Qred GitHub organization.
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
allowed-tools: Bash(gh *)
---

Layered repository exploration and code searching across the Qred GitHub organization — orient first, then navigate, search, and read only what is relevant.

## Exploration Philosophy

- **Orient before reading** — understand a repo's purpose and structure before opening any code file
- **Search, don't scan** — use keyword search to find relevant code instead of reading files sequentially
- **Read the minimum** — only open files directly relevant to the question at hand
- **Documentation first** — always prefer README and docs over source code for understanding intent
- **Bound every operation** — limit search results, truncate large files, and cap directory depth

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

## Input Classification

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

## Process

### 1. Pre-flight

1. Run `gh auth status` and confirm authentication is active
2. **Stop conditions:**
   - `gh` not installed → "Install with `brew install gh`, then `gh auth login`."
   - Not authenticated → "Run `gh auth login` to authenticate."
   - No Qred org access → "Ensure your GitHub account has access to the Qred organization."

### 2. Route Request

Route `$ARGUMENTS` using the Input Classification tables:
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

## Output Principles

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for listings, code blocks for file contents, tree format for directories (see `@references/formatting.md`)
- **Bounded output** — Truncate large results with clear indicators of what was omitted
- **Follow-up suggestions** — After each layer, suggest the natural next action (see `@references/formatting.md`)

## Argument Handling

| Argument | Behavior |
|---|---|
| (none) or `repos` | List repositories in the Qred org |
| Repo name (e.g., `qred-mcp-proxy`) | Orient: view repo details, README, and summary |
| `tree <repo>` or `<repo>/<path>/` | Navigate: tree view or directory listing |
| Search term (no path separators) | Search: find term across all Qred repos |
| `<term> in <repo>` | Search: find term in a specific repo |
| `<repo>/<file-path>` | Read: file contents with 300-line guardrail |
| `prs/issues <repo>` or `pr/issue <repo> #<n>` | Direct: list or view PRs/issues |
| Starts with `gh` | Direct: pass-through gh command |

See `@references/examples-and-errors.md` for full invocation examples and detailed error responses.

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

When an error occurs, always show the error and suggest the most helpful next action.

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/explore` | Deep end-to-end investigation of locally cloned code |
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |
| `/diagram` | Visualize repo architecture or relationships |
| `/architecture` | Design or evaluate architecture after repo exploration |

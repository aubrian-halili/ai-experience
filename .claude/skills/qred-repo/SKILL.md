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

**List Repos**
1. Run `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt`
2. Present as a table with name, description, and last push date

**List PRs**
1. Run `gh pr list -R Qred/<repo> --limit 20 --json number,title,state,author,updatedAt`
2. Present as a table with PR number, title, author, and last updated

**View PR**
1. Run `gh pr view <n> -R Qred/<repo> --json number,title,body,state,author`
2. Present PR title, author, state, and body content

**List Issues**
1. Run `gh issue list -R Qred/<repo> --limit 20 --json number,title,state,author,updatedAt`
2. Present as a table with issue number, title, author, and last updated

**View Issue**
1. Run `gh issue view <n> -R Qred/<repo> --json number,title,body,state,author`
2. Present issue title, author, state, and body content

### 3. Layered Exploration Workflow

#### Layer 1: Orient

**Purpose:** Understand the repo before diving into code.

1. Run `gh repo view Qred/<repo>` to get README and metadata
2. Summarize the repo's purpose in 2-3 sentences
3. Present: language, stars, last push, and key README sections

**Guardrails:**
- Never skip this layer when exploring a repo for the first time
- Do not auto-navigate into directories — let the user decide where to go next

**Follow-up suggestions:** Suggest `tree <repo>` for structure overview, or search for specific terms.

#### Layer 2: Navigate

**Purpose:** Understand directory structure without reading file contents.

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get directory listing
2. Present as an indented tree view (see Tree View Format below)

**Guardrails:**
- Max 3 directory levels deep per operation
- Max 30 entries per directory listing — if exceeded, show first 30 and note the remainder
- Only follow paths relevant to the user's question — do not expand every directory

**Follow-up suggestions:** Suggest searching for specific terms, or reading a specific file.

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

**Guardrails:**
- Cap results at 30 (use `--limit 30`) — if results hit the cap, always show the truncation block with refinement commands
- Do not auto-read all matching files — pick the 1-2 most relevant or let the user choose
- Present matches with enough context to judge relevance before reading

**Follow-up suggestions:** Suggest reading specific files from the results, or narrowing the search.

#### Layer 4: Read

**Purpose:** Read a single file's contents when you know it's relevant.

1. Run `gh api repos/Qred/<repo>/contents/<path>` to get file metadata and encoded content
2. Decode the content: pipe through `jq -r '.content' | base64 -d`
3. Present file contents in a syntax-highlighted code block

**Guardrails:**
- One file at a time — do not batch-read multiple files
- **300-line threshold:** If a file exceeds 300 lines, show the first 100 lines and ask the user before showing more
- Skip binary files, generated files, and lock files (e.g., `package-lock.json`, `yarn.lock`, `.min.js`, compiled output) — note that these were skipped
- Summarize the file's purpose before presenting raw content

**Follow-up suggestions:** Suggest reading related files, searching for specific symbols, or navigating to parent directory.

### 4. Tree View Format

When presenting directory structures, use this indented format:

```
Qred/<repo>
+-- README.md
+-- package.json
+-- src/
|   +-- index.ts
|   +-- config/
|   |   +-- database.ts
|   |   +-- auth.ts
|   +-- routes/
|       +-- (...)
+-- tests/
|   +-- (...)
+-- docs/
    +-- architecture.md
```

- Use `+--` for entries and `|` for continuation lines
- Annotate key directories with brief descriptions when their purpose is clear (e.g., `src/ — application source`)
- Mark unexplored directories with `(...)` to indicate more content exists
- Respect the 3-level depth limit — show `(...)` for deeper levels

### 5. Present Results

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for listings, code blocks for file contents and command output, tree format for directory structures
- **Bounded output** — Truncate large results with clear indicators of what was omitted
- **Focused follow-ups** — Suggest next actions based on the current layer:
  - After orient → suggest tree view or code search
  - After navigate → suggest searching for terms or reading specific files
  - After search → suggest reading the most relevant matching files
  - After read → suggest related files, broader search, or navigating to parent directory

## Guardrails

| Rule | Rationale |
|---|---|
| Read README before code files | Documentation provides context that prevents misinterpretation |
| Max 3 directory levels per operation | Prevents irrelevant file listing that dilutes attention |
| Cap search at 30 results; show refinement options on truncation | Keeps output focused — when results hit the cap, show a refinement block with copy-paste commands to narrow scope, filter by repo, or increase limit |
| 300-line file threshold | Preserves context budget for what matters |
| Skip binary/generated/lock files | These contain no useful information for exploration |
| One file at a time | Maintains focus and prevents context overload |
| Summarize before raw content | Helps user decide relevance before committing attention |
| Suggest next actions, don't auto-execute | User drives exploration depth — never auto-expand |

## Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo` | List repositories in the Qred org |
| `/qred-repo qred-mcp-proxy` | Orient: view repo details, README, and summary |
| `/qred-repo tree qred-mcp-proxy` | Navigate: show directory tree (max 3 levels) |
| `/qred-repo qred-mcp-proxy/src/` | Navigate: list files in `src/` directory |
| `/qred-repo qred-mcp-proxy/README.md` | Read: file contents with 300-line guardrail |
| `/qred-repo OAuth` | Search: find "OAuth" across all Qred repos (max 30 results) |
| `/qred-repo fetchUser in qred-api` | Search: find "fetchUser" in qred-api repo |
| `/qred-repo prs qred-mcp-proxy` | Direct: list open PRs in qred-mcp-proxy |
| `/qred-repo pr qred-mcp-proxy #42` | Direct: view PR #42 details |
| `/qred-repo issues qred-api` | Direct: list open issues in qred-api |
| `/qred-repo gh repo list Qred --language typescript` | Direct: pass-through gh command |

## Error Handling

| Scenario | Response |
|---|---|
| `gh` not installed | "GitHub CLI is not installed. Install with `brew install gh` and run `gh auth login`." |
| Not authenticated | "Run `gh auth login` to authenticate with GitHub." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |
| Repo not found | Suggest listing repos with `/qred-repo` to find the correct name |
| File/path not found | List parent directory contents to help navigate |
| File too large (>300 lines) | Show first 100 lines and ask: "This file has N lines. Show more?" |
| Directory >30 entries | Show first 30 entries and note: "Showing 30 of N entries. Narrow with a path or search." |
| No search results | Suggest alternative terms, broader scope, or different repo |
| PR/issue not found | Show error and suggest listing PRs/issues |
| API rate limit | "GitHub API rate limit exceeded. Wait a few minutes and retry." |

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/explore` | Deep end-to-end investigation of locally cloned code |
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |

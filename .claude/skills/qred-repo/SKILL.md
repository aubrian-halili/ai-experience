---
name: qred-repo
description: Use when the user asks to "list repos", "show repo", "read file from repo", "search code", "find in org", "browse repo", mentions "Qred repos", "GitHub org", "qred org", or needs lightweight repository navigation and code searching across the Qred GitHub organization.
argument-hint: "[repo name, file path, search term, or gh command]"
---

# Qred Repository Navigator

Lightweight repository navigation and code searching across the Qred GitHub organization — list repos, browse files, read content, search code, and view PRs/issues using the GitHub CLI.

## When to Use

### This Skill Is For

- Listing repositories in the Qred GitHub organization
- Browsing files and directories in a Qred repo (without cloning)
- Reading file contents from a Qred repo
- Searching code across repos in the Qred org
- Viewing pull requests and issues in Qred repos

### Use a Different Approach When

- Working with locally cloned files → use Glob, Read, Grep directly
- Deep end-to-end feature investigation → use `/explore`
- Reviewing code quality or PR changes → use `/review`
- Querying PostgreSQL databases → use `/backoffice-database`

## Process

### 0. Pre-flight Check

1. Run `gh auth status` and confirm authentication is active
2. Stop conditions:
   - `gh` not installed → "Install with `brew install gh`, then `gh auth login`."
   - Not authenticated → "Run `gh auth login` to authenticate."
   - No Qred org access → "Ensure your GitHub account has access to the Qred organization."

### 1. Determine Intent

Parse `$ARGUMENTS` to route to the correct operation:

| Argument Pattern | Intent | Command |
|---|---|---|
| (empty) or `repos` | List Qred org repos | `gh repo list Qred --limit 30` |
| Repo name only (e.g., `qred-mcp-proxy`) | View repo details | `gh repo view Qred/<repo>` |
| `<repo>/` or `<repo>/<path>/` | List directory contents | `gh api repos/Qred/<repo>/contents/<path>` |
| `<repo>/<file-path>` | Read file contents | `gh api repos/Qred/<repo>/contents/<path>` + decode base64 |
| Search term (no path separators) | Search code across org | `gh search code --owner Qred "<term>"` |
| `<term> in <repo>` | Search code in specific repo | `gh search code --repo Qred/<repo> "<term>"` |
| `prs <repo>` or `pr list <repo>` | List PRs | `gh pr list -R Qred/<repo>` |
| `pr <repo> #<n>` | View specific PR | `gh pr view <n> -R Qred/<repo>` |
| `issues <repo>` | List issues | `gh issue list -R Qred/<repo>` |
| `issue <repo> #<n>` | View specific issue | `gh issue view <n> -R Qred/<repo>` |
| Starts with `gh` | Pass-through gh command | Execute as-is |

### 2. Execute Operation

**List Repos**
1. Run `gh repo list Qred --limit 30 --no-archived --json name,description,url,isArchived,pushedAt`
2. Present as a table with name, description, and last push date

**View Repo**
1. Run `gh repo view Qred/<repo>` to display README and metadata
2. Present repository description, language, stars, and README content

**List Directory**
1. Run `gh api repos/Qred/<repo>/contents/<path>` to get directory listing
2. Parse the JSON array and present as a table with columns: name, type, size

**Read File**
1. Run `gh api repos/Qred/<repo>/contents/<path>` to get file metadata and encoded content
2. Decode the content: pipe through `jq -r '.content' | base64 -d`
3. Present file contents in a syntax-highlighted code block

**Search Code**
1. Run `gh search code --owner Qred "<term>" --limit 30 --json path,repository,textMatches`
2. For repo-scoped search: `gh search code --repo Qred/<repo> "<term>" --limit 30 --json path,repository,textMatches`
3. Present matching files with repository, path, and matched text

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

### 3. Present Results

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for listings, code blocks for file contents and command output
- **Bounded output** — Truncate large results with clear indicators of what was omitted
- **Next steps** — Suggest related operations (e.g., after listing repos, suggest viewing a specific repo; after listing a directory, suggest reading a file)

## Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo` | List repositories in the Qred org |
| `/qred-repo qred-mcp-proxy` | View repo details and README |
| `/qred-repo qred-mcp-proxy/src/` | List files in `src/` directory |
| `/qred-repo qred-mcp-proxy/README.md` | Read README file contents |
| `/qred-repo OAuth` | Search for "OAuth" across all Qred repos |
| `/qred-repo fetchUser in qred-api` | Search for "fetchUser" in qred-api repo |
| `/qred-repo prs qred-mcp-proxy` | List open PRs in qred-mcp-proxy |
| `/qred-repo pr qred-mcp-proxy #42` | View PR #42 details |
| `/qred-repo issues qred-api` | List open issues in qred-api |
| `/qred-repo gh repo list Qred --language typescript` | Pass-through: list TypeScript repos |

## Error Handling

| Scenario | Response |
|---|---|
| `gh` not installed | "GitHub CLI is not installed. Install with `brew install gh` and run `gh auth login`." |
| Not authenticated | "Run `gh auth login` to authenticate with GitHub." |
| No Qred org access | "Ensure your GitHub account has access to the Qred organization." |
| Repo not found | Suggest listing repos with `/qred-repo` to find the correct name |
| File/path not found | List parent directory contents to help navigate |
| No search results | Suggest alternative terms, broader scope, or different repo |
| PR/issue not found | Show error and suggest listing PRs/issues |
| API rate limit | "GitHub API rate limit exceeded. Wait a few minutes and retry." |

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/explore` | Deep end-to-end investigation of locally cloned code |
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |

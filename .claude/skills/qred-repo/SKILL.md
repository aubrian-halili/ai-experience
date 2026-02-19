---
name: qred-repo
description: Use when the user asks to "list files", "show directory", "read file", "find files", "search code", "grep for", "show me", mentions "file structure", "project layout", "codebase search", or needs lightweight repository navigation and code searching.
argument-hint: "[path, glob pattern, search term, or git command]"
---

# Repository Navigator

Lightweight repository navigation and code searching — browse directories, read files, find files by pattern, search code, and run read-only git commands.

## When to Use

### This Skill Is For

- Listing directory contents and browsing project structure
- Reading specific files or line ranges
- Finding files by glob pattern (e.g., `**/*.ts`, `src/**/index.*`)
- Searching code across the codebase by keyword or regex
- Running read-only git commands (log, blame, diff, show)

### Use a Different Approach When

- Deep end-to-end feature investigation → use `/explore`
- Reviewing code quality or PR changes → use `/review`
- Querying PostgreSQL databases → use `/backoffice-database`
- Visualizing architecture or flows → use `/diagram`

## Process

### 1. Determine Intent

Parse `$ARGUMENTS` to route to the correct operation:

| Argument Pattern | Intent | Tool |
|---|---|---|
| (empty) | Overview — list project root | Glob |
| Path ending in `/` or known directory | List directory contents | Glob |
| Contains `*`, `?`, or `**` | Find files matching glob pattern | Glob |
| File path with extension, no wildcards | Read file contents | Read |
| File path with `:START-END` suffix | Read specific line range | Read |
| Wrapped in `/pattern/` or plain text without path separators | Search code across codebase | Grep |
| `<term> in <path>` or `<term> *.ext` | Scoped search within path or file type | Grep |
| Starts with `git log`, `git blame`, `git diff`, `git show` | Git read-only operation | Bash |

**Ambiguity resolution**: If the argument could be either a path or a search term, check if it resolves to an existing file or directory first. If it does, read or list it. Otherwise, treat it as a search term.

### 2. Execute Operation

**Overview (no arguments)**
1. Use Glob with `*` at the project root to list top-level files and directories
2. Present the project structure with a brief orientation

**List Directory**
1. Use Glob with `<path>/*` to list immediate contents
2. For deeper listing, use `<path>/**/*` with a reasonable depth limit
3. Group results by type: directories first, then files

**Find Files (glob pattern)**
1. Use Glob with the provided pattern
2. Present matching files sorted by path
3. If too many results (>50), summarize by directory and suggest narrowing the pattern

**Read File**
1. Use Read with the file path
2. If a line range is specified (e.g., `file.ts:10-50`), pass `offset` and `limit` parameters
3. Present the file contents with syntax context

**Search Code**
1. Use Grep with the search term or regex pattern
2. For scoped searches (`<term> in <path>`), set the `path` parameter
3. For file type scopes (`<term> *.ext`), set the `glob` parameter
4. Show matching lines with file locations in `file:line` format
5. If too many results (>30 files), summarize by directory and suggest narrowing the scope

**Git Read-Only**
1. Execute only these git subcommands: `log`, `blame`, `diff`, `show`
2. Pass the full command to Bash
3. Present results with clear formatting

### 3. Present Results

- **Context first** — State what was searched/listed and where
- **Structured presentation** — Use tables for file listings, code blocks for file contents and git output
- **Bounded output** — Truncate large results with clear indicators of what was omitted
- **Next steps** — Suggest related operations (e.g., after listing a directory, suggest reading a specific file; after searching, suggest narrowing scope)

## Example Invocations

| Invocation | What It Does |
|---|---|
| `/qred-repo` | List project root files and directories |
| `/qred-repo src/` | List contents of the `src/` directory |
| `/qred-repo **/*.md` | Find all markdown files in the project |
| `/qred-repo src/**/*.test.ts` | Find all test files under `src/` |
| `/qred-repo README.md` | Read the README file |
| `/qred-repo src/index.ts:10-50` | Read lines 10-50 of `src/index.ts` |
| `/qred-repo handleAuth` | Search codebase for "handleAuth" |
| `/qred-repo /TODO\|FIXME/` | Search for TODO or FIXME comments using regex |
| `/qred-repo fetchUser in src/api/` | Search for "fetchUser" within `src/api/` |
| `/qred-repo useState *.tsx` | Search for "useState" in `.tsx` files |
| `/qred-repo git log --oneline -20` | Show last 20 commits |
| `/qred-repo git blame src/index.ts` | Show blame for a file |
| `/qred-repo git diff main` | Show diff against main branch |

## Error Handling

| Scenario | Response |
|---|---|
| File not found | Suggest similar file paths using Glob and ask the user to confirm |
| Directory not found | List parent directory contents to help the user navigate |
| No search results | Suggest alternative search terms, broader patterns, or case-insensitive search |
| Too many results | Summarize by directory, show top results, and suggest narrowing the query |
| Invalid glob pattern | Show the error and suggest a corrected pattern |
| Disallowed git command | "Only read-only git commands are allowed: `log`, `blame`, `diff`, `show`. For write operations, use `/commit` or `/pr`." |
| Git command fails | Show the error message and suggest corrections |

## Related Skills

| Skill | When to Use Instead |
|---|---|
| `/explore` | Deep end-to-end investigation of how a feature works |
| `/review` | Code quality review or PR audit |
| `/backoffice-database` | Exploring PostgreSQL database schemas and data |
| `/diagram` | Visualizing project architecture or flows |

---
name: confluence
description: >-
  User asks to "create a Confluence page", "view a Confluence page", "update a page",
  "find a page", "write documentation in Confluence", "list spaces", "search blogs",
  or mentions "Confluence" in context of reading, writing, or updating pages.
  Not for: Jira ticket management (use /jira).
  Not for: syncing local repo documentation like CLAUDE.md (use /doc-sync).
argument-hint: "[view <page-id> | update <page-id> | search <query> | blogs <space-id> | spaces]"
allowed-tools: Bash(acli confluence page view *, acli confluence space list *, acli confluence space view *, acli confluence blog list *, acli confluence blog view *, acli --version)
disable-model-invocation: true
---

## Guardrails

This skill is scoped to **read and generate** operations only. All operations target `qredab.atlassian.net`. Prefer `--json` on all acli commands.

**Forbidden actions**: `space archive`, `space restore`, `space create`, `space update`.

## Input Handling

Determine operation intent from `$ARGUMENTS`:

| Input | Intent |
|-------|--------|
| `view <page-id>` | View a specific page by ID |
| `view <confluence-url>` | View a specific page by URL |
| `update <page-id>` / `edit <page-id>` | Update a page |
| `search <query>` / `find <query>` | Search for content |
| `blogs <space-id>` / `list blogs` | Browse blog posts |
| `spaces` / `list spaces` | List available spaces |
| `space <space-id>` / `view space <space-id>` | View a specific space |
| `page <title or description>` | Create a page |

## Process

### 1. Pre-flight

Run `acli --version`; if unavailable, use Markdown-paste fallbacks (Steps 3, 7).

### 2. View Page

- Run `acli confluence page view --id <PAGE_ID> --body-format storage`
- Key flags: `--body-format` (storage|atlas_doc_format|view), `--include-labels`, `--include-versions`, `--version <N>`, `--get-draft`, `--status` (current|draft|archived)

### 3. Update Page (Fallback)

- First, fetch current page content: `acli confluence page view --id <PAGE_ID> --body-format storage`
- Output: Markdown diff summary + full updated content + edit URL: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/edit-v2/<PAGE_ID>`

### 4. Search

- For blog content: `acli confluence blog list --space-id <SPACE_ID> --title "<query>"`
- For page content: note the acli limitation and suggest Confluence web search: `https://qredab.atlassian.net/wiki/search?text=<query>`

### 5. List / View Blogs

- List: `acli confluence blog list --space-id <SPACE_ID>`
  - Key flags: `--title` (filter by title), `--status` (current|draft|deleted), `--limit`, `--body-format`
- View a specific post: `acli confluence blog view --id <BLOG_ID> --body-format view`
  - Key flags: `--body-format` (view|storage|atlas_doc_format), `--include` (labels,properties,versions,collaborators), `--draft`, `--version <N>`

### 6. List Spaces

- Run `acli confluence space list`
- Key flags: `--type` (global|personal), `--keys` (filter by space keys), `--status` (current|archived), `--limit`, `--expand` (description|homepage|permissions)
- View a specific space: `acli confluence space view --id <SPACE_ID>`

### 7. Create Page (Fallback)

- Output: full page content in Markdown format + direct link to create: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/create`

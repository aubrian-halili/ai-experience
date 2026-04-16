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

## Confluence Philosophy

- **Graceful degradation** — when acli lacks a command (page create/update), generate copy-ready Markdown content for manual entry
- **Instance-scoped** — all operations target `qredab.atlassian.net`

## Guardrails

This skill is scoped to **read and generate** operations only.

**Forbidden actions**: `space archive`, `space restore`, `space create`, `space update` — these are administrative operations. If requested, refuse and direct the user to manage these directly in Confluence.

## Input Handling

Determine operation intent from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| `view <page-id>` | View a specific page by ID | Step 2 (View Page) |
| `view <confluence-url>` | View a specific page by URL | Step 2 (View Page) — extract ID from URL |
| `update <page-id>` / `edit <page-id>` | Update a page (no acli support) | Step 3 (Update Fallback) |
| `search <query>` / `find <query>` | Search for content | Step 4 (Search) |
| `blogs <space-id>` / `list blogs` | Browse blog posts | Step 5 (List/View Blogs) |
| `spaces` / `list spaces` | List available spaces | Step 6 (List Spaces) |
| `space <space-id>` / `view space <space-id>` | View a specific space | Step 6 (List Spaces) |
| `page <title or description>` | Create a page (no acli support) | Step 7 (Create Fallback) |

## Process

### 1. Pre-flight

- Check acli availability: run `acli --version`
  - acli available → proceed with native commands for read operations
  - acli unavailable → skip to content generation fallback and note the issue

### 2. View Page

Fetch and display a Confluence page by ID or URL:

- Run `acli confluence page view --id <PAGE_ID> --body-format storage --json`
- Key flags: `--body-format` (storage|atlas_doc_format|view), `--include-labels`, `--include-versions`, `--version <N>`, `--get-draft`, `--status` (current|draft|archived)
- Direct URL format: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/<PAGE_ID>`

### 3. Update Page (Fallback)

- First, fetch current page content: `acli confluence page view --id <PAGE_ID> --body-format storage`
- Apply the requested changes to the content
- Present:
  1. **What changed** — a brief diff summary (sections added/removed/modified)
  2. **Full updated content** in Markdown format (Confluence editor accepts Markdown paste)
  3. **Direct link** to edit the page: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/edit-v2/<PAGE_ID>`

### 4. Search

- For blog content: `acli confluence blog list --space-id <SPACE_ID> --title "<query>" --json`
- For page content: note the acli limitation and suggest Confluence web search: `https://qredab.atlassian.net/wiki/search?text=<query>`

### 5. List / View Blogs

Browse and view blog posts in a space:

- List: `acli confluence blog list --space-id <SPACE_ID> --json`
  - Key flags: `--title` (filter by title), `--status` (current|draft|deleted), `--limit` (default 25), `--body-format`, `--json`
- View a specific post: `acli confluence blog view --id <BLOG_ID> --body-format view --json`
  - Key flags: `--body-format` (view|storage|atlas_doc_format), `--include` (labels,properties,versions,collaborators), `--draft`, `--version <N>`

### 6. List Spaces

List all accessible Confluence spaces:

- Run `acli confluence space list --json`
- Key flags: `--type` (global|personal), `--keys` (filter by space keys), `--status` (current|archived, default: current), `--limit` (default 50), `--expand` (description|homepage|permissions)
- View a specific space: `acli confluence space view --id <SPACE_ID> --json`

### 7. Create Page (Fallback)

- Present:
  1. **Full page content** in Markdown format (ready to paste into Confluence editor)
  2. **Direct link** to create a new page in the target space: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/create`

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Create or manage Jira tickets (not Confluence pages) |

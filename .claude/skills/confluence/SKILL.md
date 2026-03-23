---
name: confluence
description: >-
  User asks to "create a Confluence page", "view a Confluence page", "update a page",
  "find a page", "write documentation in Confluence", "list spaces", "search blogs",
  or mentions "Confluence" in context of reading, writing, or updating pages.
  Not for: Jira ticket management (use /jira).
argument-hint: "[view <page-id> | update <page-id> | search <query> | blogs <space-id> | spaces]"
allowed-tools: Bash(acli confluence page view *, acli confluence space list *, acli confluence space view *, acli confluence blog list *, acli confluence blog view *, acli --version)
disable-model-invocation: true
---

View Confluence pages, browse spaces and blog posts, and generate ready-to-paste Markdown content for manual page creation and updates on the Qred Atlassian instance.

## Confluence Philosophy

- **Read-first orientation** — viewing and searching existing content is the primary use case; page creation and update are assisted via Markdown generation
- **Graceful degradation** — when acli lacks a command (page create/update), generate copy-ready Markdown content for manual entry rather than failing
- **Instance-scoped** — all operations target `qredab.atlassian.net`; never assume a different instance
- **User-owned publishing** — never publish autonomously; the user always controls what lands in Confluence

## Guardrails

This skill is scoped to **read and generate** operations only. The following rules apply:

**Allowed actions**: `page view`, `space list`, `space view`, `blog list`, `blog view`, and Markdown content generation for page create/update

**Forbidden actions**: `space archive`, `space restore`, `space create`, `space update` — these are administrative operations. If requested, refuse and direct the user to manage these directly in Confluence.

**Sensitive data exclusion**: Before generating any page content, scan for secrets, credentials, API keys, tokens, connection strings, and PII. Strip or redact any sensitive values — Confluence content is visible to all space members.

## Iron Laws

> - NEVER generate content containing secrets, credentials, API keys, or connection strings
> - NEVER execute administrative space commands (`archive`, `restore`, `create`, `update`)
> - ALWAYS present generated content for user review before they paste it manually
> - ALWAYS include the direct Confluence URL after any read operation

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
| `(none)` | Unclear intent | Pre-flight stop — ask user |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent using the Input Handling table
- Check acli availability: run `acli --version`
  - acli available → proceed with native commands for read operations
  - acli unavailable → skip to content generation fallback and note the issue
- If no arguments provided → ask the user what they'd like to do (view a page, browse spaces, create/update content)

**Stop conditions:**
- No arguments and context is unclear → ask user to specify: view, update, search, blogs, spaces, or page create
- Administrative space operation requested → refuse: "Administrative space commands are outside this skill's scope — manage these directly in Confluence"

### 2. View Page

Fetch and display a Confluence page by ID or URL:

- If a full Confluence URL is provided, extract the page ID (the number after `/pages/` in the URL path) before running the command
- Run `acli confluence page view --id <PAGE_ID> --body-format storage --json`
- Key flags: `--body-format` (storage|atlas_doc_format|view), `--include-labels`, `--include-versions`, `--version <N>`, `--get-draft`, `--status` (current|draft|archived)
- Present: page title, content summary, labels, last modified, and direct URL: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/<PAGE_ID>`
- If user needs the raw storage format (for update fallback), retain full body

### 3. Update Page (Fallback)

Since `acli confluence page update` does not exist, generate updated content for manual paste:

- First, fetch current page content: `acli confluence page view --id <PAGE_ID> --body-format storage`
- Understand what changes the user wants (from conversation context or `$ARGUMENTS`)
- Apply changes to the content using the Page Update template from `@references/templates.md`
- Present:
  1. **What changed** — a brief diff summary (sections added/removed/modified)
  2. **Full updated content** in Markdown format (Confluence editor accepts Markdown paste)
  3. **Direct link** to edit the page: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/edit-v2/<PAGE_ID>`

### 4. Search

Since there is no dedicated `acli confluence search` command:

- For blog content: `acli confluence blog list --space-id <SPACE_ID> --title "<query>" --json`
- For page content: note the acli limitation and suggest Confluence web search: `https://qredab.atlassian.net/wiki/search?text=<query>`
  - If `acli` adds search support in the future, the query language is CQL: `type=page AND text ~ "<query>"`
- If space ID is not known, first run Step 6 (List Spaces) and ask user to pick one

### 5. List / View Blogs

Browse and view blog posts in a space:

- List: `acli confluence blog list --space-id <SPACE_ID> --json`
  - Key flags: `--title` (filter by title), `--status` (current|draft|deleted), `--limit` (default 25), `--body-format`, `--json`
- View a specific post: `acli confluence blog view --id <BLOG_ID> --body-format view --json`
  - Key flags: `--body-format` (view|storage|atlas_doc_format), `--include` (labels,properties,versions,collaborators), `--draft`, `--version <N>`
- Present: title, author, space, publish date, content summary, and URL

### 6. List Spaces

List all accessible Confluence spaces:

- Run `acli confluence space list --json`
- Key flags: `--type` (global|personal), `--keys` (filter by space keys), `--status` (current|archived, default: current), `--limit` (default 50), `--expand` (description|homepage|permissions)
- View a specific space: `acli confluence space view --id <SPACE_ID> --json`
- Present as a table: space key, name, type, URL

### 7. Create Page (Fallback)

Since `acli confluence page create` does not exist, generate copy-ready content for manual creation:

- Gather content from conversation context (topic, purpose, audience, key sections)
- Apply the Page Create template from `@references/templates.md`
- Present:
  1. **Full page content** in Markdown format (ready to paste into Confluence editor)
  2. **Direct link** to create a new page in the target space: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/create`
  3. **Instruction**: "Paste this content into the Confluence editor — it accepts Markdown directly"
- If target space is unknown, first run Step 6 (List Spaces) and ask user to confirm

## Output Principles

- **Content preview before action** — always present generated Markdown for review before the user pastes it; include a clear "Copy and paste into Confluence" instruction
- **Actionable results** — every operation ends with a direct Confluence URL (page, edit, search, or space)
- **Capability transparency** — clearly state when an operation requires manual steps due to acli limitations; explain the exact manual steps
- **Format awareness** — page content is generated in Markdown; Confluence's editor converts it on paste

## Error Handling

| Scenario | Response |
|----------|----------|
| acli not available | Fall back to content generation for writes; for reads, suggest running `acli confluence auth login` |
| Authentication error | "Run `acli confluence auth login` to authenticate, then retry" |
| Page ID not found | "Page not found — verify the page ID from the Confluence URL (it's the number after `/pages/`)" |
| Space ID unknown | List available spaces via Step 6 and ask user to pick one |
| Space ID not found | "Space not found — run `/confluence spaces` to list available spaces" |
| No conversation context for page creation | Ask user to describe the page topic, purpose, and key sections |
| API error (non-auth) | Present content generation fallback and include Confluence web URL for manual action |
| Administrative operation requested | Refuse: "Administrative space commands are outside this skill's scope — manage these directly in Confluence" |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Create or manage Jira tickets (not Confluence pages) |
| `/plan` | Decompose work into implementation phases (may reference Confluence for design docs) |
| `/feature` | Implement features (may reference Confluence specs) |
| `/pr` | Create pull requests (may link to Confluence documentation) |

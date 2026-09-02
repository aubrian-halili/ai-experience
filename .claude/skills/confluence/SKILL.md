---
name: confluence
description: >-
  User asks to "view a Confluence page", "find/search a page", "list spaces", "search blogs",
  "read Confluence", or wants to draft/preview a new or updated Confluence page, or publish a blog post.
  Scoped to qredab.atlassian.net; pages are read-only via acli (create/update are delivered as Markdown + an edit URL fallback),
  blog posts can be created directly as drafts.
  Not for: Jira ticket management (use /jira); not for: syncing local repo docs like CLAUDE.md (use /doc-sync).
argument-hint: "[view <page-id> | update <page-id> | search <query> | blogs <space-id> | blog <title> | spaces]"
allowed-tools: Bash(acli confluence page view *, acli confluence space list *, acli confluence space view *, acli confluence blog list *, acli confluence blog view *, acli confluence blog create *, acli --version), Write(.confluence/*.xhtml)
disable-model-invocation: true
---

## Guardrails

All operations target `qredab.atlassian.net`. Prefer `--json` on all acli commands.

**Pages are read-only** — acli has no `page create` or `page update`, so new and edited page content is delivered as Markdown plus an edit URL (Steps 3, 7).

**Blog posts may be created, as drafts only.** `acli confluence blog create` defaults to `--status current`, which **publishes immediately**. Always pass `--status draft`. Publishing requires the user to say so explicitly in the current turn — never infer it from "create a blog post".

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
| `blog <title or description>` | Create a blog post draft |
| `spaces` / `list spaces` | List available spaces |
| `space <space-id>` / `view space <space-id>` | View a specific space |
| `page <title or description>` | Create a page |

## Process

### 1. Pre-flight

Run `acli --version`; if unavailable, use Markdown-paste fallbacks (Steps 3, 7) and skip Step 8.

### 2. View Page

- Run `acli confluence page view --id <PAGE_ID> --body-format storage`
- `--status` takes a comma-separated list (current,draft,archived); `--include-direct-children` is the only way to walk a page tree. Other flags: `acli confluence page view --help`

### 3. Update Page (Fallback)

- First, fetch current page content: `acli confluence page view --id <PAGE_ID> --body-format storage`
- Output: Markdown diff summary + full updated content + edit URL: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/edit-v2/<PAGE_ID>`

### 4. Search

- For blog content: `acli confluence blog list --space-id <SPACE_ID> --title "<query>"`
- For page content: acli has no page-search command — suggest Confluence web search: `https://qredab.atlassian.net/wiki/search?text=<query>`

### 5. List / View Blogs

- List: `acli confluence blog list --space-id <SPACE_ID>`
  - `--status` takes a comma-separated list of current,deleted,trashed — there is no `draft` here. `--limit` defaults to 25; page with `--cursor` (token from the previous response) rather than raising the limit.
- View a specific post: `acli confluence blog view --id <BLOG_ID> --body-format view`
  - `--body-format` defaults to `view`; `--status` defaults to `current` and accepts `draft`.

### 6. List Spaces

- Run `acli confluence space list`
- `--type` (global|personal), `--keys` (comma-separated space keys), `--limit` defaults to 50, `--status` defaults to `current`
- View a specific space: `acli confluence space view --id <SPACE_ID>` (`--include-all` for every detail section)
- Space IDs are numeric and differ from space keys. Resolve a key to an ID with `acli confluence space list --keys <KEY> --json` before any command taking `--space-id`.

### 7. Create Page (Fallback)

- Output: full page content in Markdown format + direct link to create: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/create`

### 8. Create Blog Post (Draft)

1. **Resolve the space ID** (Step 6).
2. **Author the body in Confluence storage format (XHTML)**, not Markdown — `--body`/`--from-file` content is stored as given, so Markdown syntax renders literally. Save it to `.confluence/<slug>.xhtml` so the draft stays reviewable and re-runnable.
3. **Show the user the body and the target space, and get confirmation** before calling acli.
4. **Create the draft**:
   ```bash
   acli confluence blog create --space-id <SPACE_ID> --title "<TITLE>" \
     --from-file .confluence/<slug>.xhtml --status draft --json
   ```
5. **Report the draft** — read the ID and links straight from the `--json` response and give the user that URL rather than constructing one. Publishing is a separate step the user takes in Confluence (or by re-running with `--status current`, which requires their explicit go-ahead).

On non-zero exit, nothing was created in Confluence — say so, and offer Step 7's paste fallback.

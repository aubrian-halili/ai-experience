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

**Pages are read-only** — acli exposes only `page view`; there is no `page create` or `page update`, so new and edited page content is delivered as Markdown plus an edit URL (Steps 3, 7).

**Blog posts may be created, as drafts only.** `acli confluence blog create` defaults to `--status current`, which **publishes immediately**. Always pass `--status draft`. Publishing (`--status current`) requires the user to say so explicitly in the current turn — never infer it from "create a blog post".

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
- Key flags: `--body-format` (storage|atlas_doc_format|view), `--version <N>`, `--get-draft`, `--status` (comma-separated: current,draft,archived)
- Include flags: `--include-labels`, `--include-direct-children` (child pages — the only way to walk a page tree), `--include-version` (detailed version object), `--include-versions` (version list), `--include-properties`, `--include-collaborators`, `--include-likes`, `--include-operations`, `--include-webresources`

### 3. Update Page (Fallback)

- First, fetch current page content: `acli confluence page view --id <PAGE_ID> --body-format storage`
- Output: Markdown diff summary + full updated content + edit URL: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/edit-v2/<PAGE_ID>`

### 4. Search

- For blog content: `acli confluence blog list --space-id <SPACE_ID> --title "<query>"`
- For page content: acli has no page-search command — suggest Confluence web search: `https://qredab.atlassian.net/wiki/search?text=<query>`

### 5. List / View Blogs

- List: `acli confluence blog list --space-id <SPACE_ID>`
  - Key flags: `--title` (filter by title), `--id` (comma-separated IDs), `--status` (comma-separated: current,deleted,trashed — note there is no `draft` here), `--space-id` (accepts comma-separated IDs), `--sort`, `--limit`/`-l` (default 25), `--cursor` (pagination token from a previous response's output — use it rather than raising `--limit` for large spaces), `--body-format` (storage|atlas_doc_format), `--csv`
- View a specific post: `acli confluence blog view --id <BLOG_ID> --body-format view`
  - Key flags: `--body-format` (default `view`; also storage|atlas_doc_format), `--draft`, `--version <N>`, `--status` (current|trashed|deleted|historical|draft, default current)
  - `--include` accepts a comma-separated list of: `labels`, `properties`, `operations`, `likes`, `versions`, `version`, `favorited`, `webresources`, `collaborators`, or `all`

### 6. List Spaces

- Run `acli confluence space list`
- Key flags: `--type` (global|personal), `--keys` (comma-separated space keys), `--status` (current|archived, default current), `--limit`/`-l` (default 50), `--expand` (description|homepage|permissions)
- View a specific space: `acli confluence space view --id <SPACE_ID>`
  - Key flags: `--include-all` (everything below), `--icon`, `--labels`, `--permissions`, `--properties`, `--operations`, `--role-assignments` (EAP sites only), `--desc-format` (plain|view)
- Space IDs are numeric and differ from space keys. Resolve a key to an ID with `acli confluence space list --keys <KEY> --json` before any command taking `--space-id`.

### 7. Create Page (Fallback)

- Output: full page content in Markdown format + direct link to create: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/create`

### 8. Create Blog Post (Draft)

Unlike pages, blog posts can be created directly. Draft only — see **Guardrails**.

1. **Resolve the space ID** — `acli confluence space list --keys <KEY> --json` (Step 6). `--space-id` takes the numeric ID, not the key.
2. **Author the body in Confluence storage format (XHTML)** — not Markdown. `--body`/`--from-file` content is stored as given, so Markdown syntax renders as literal `##` and `-` characters, the same way it does for Jira descriptions. Write real tags: `<h2>`, `<p>`, `<ul><li>`, `<code>`, `<a href="…">`. Save it to `.confluence/<slug>.xhtml` so the draft stays reviewable and re-runnable.
3. **Show the user the body and the target space, and get confirmation** before calling acli. This is an outward-facing write.
4. **Create the draft**:
   ```bash
   acli confluence blog create --space-id <SPACE_ID> --title "<TITLE>" \
     --from-file .confluence/<slug>.xhtml --status draft --json
   ```
   - Prefer `--from-file` over `--body` — it keeps XHTML out of the shell and off the command line.
   - `--from-json <file>` takes a whole payload instead; `--generate-json` prints its expected structure.
   - `--private` restricts the post to its creator. `--created-at` backdates it. Neither is needed for the normal path.
5. **Report the draft** — read the ID and links straight from the `--json` response and give the user that URL rather than constructing one. State plainly that the post is a **draft** and that publishing is a separate step the user takes in Confluence (or by re-running with `--status current`, which requires their explicit go-ahead).

On non-zero exit, apply `.claude/rules/tool-reliability.md` — the proceed option here is Step 7's paste fallback, stating that nothing was created in Confluence.

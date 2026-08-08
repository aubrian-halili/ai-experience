---
name: jira
description: >-
  User asks to "create Jira tickets", "decompose into tickets", "file tickets from plan",
  "break plan into Jira", or mentions "Jira" in context of creating tickets from a plan.
  Requires an approved plan in .planning/STATE.md (redirects to /plan if missing).
  Defaults to project UN (overridable); uses acli when available, otherwise emits copy-ready content.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature); not for: transitioning or editing existing tickets.
argument-hint: "[PROJECT]"
allowed-tools: Read, Write(.planning/STATE.md), Write(.planning/tickets/*.md), Edit(.planning/STATE.md), Agent, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version, python3 .claude/skills/jira/scripts/build-workitem.py *)
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

## Input Handling

Default project: `UN`. Override via `$ARGUMENTS` (e.g., `/jira PROJ`).

### Pre-flight

1. **Check for plan**: Read `.planning/STATE.md` and extract each phase's goal, observable truths, dependencies, files to create/modify, and verification commands.
   - If the file does not exist or contains no `#### Phase` headings → **stop** and redirect:
     > "No approved plan found. Run `/plan` first to create an implementation plan, then come back to `/jira` to decompose it into tickets."
2. **Check acli availability**: run `acli --version`; available → create directly via acli; unavailable → generate content for manual entry

---

## Process

### 1. Choose Ticket Granularity

Ask the user:

> "Create one ticket per plan phase, or a single ticket covering all phases?"

- **Per-phase**: proceed with one ticket per phase as below.
- **Single ticket**: draft one Task whose summary reflects the overall plan goal, with acceptance criteria = union of all observable truths across phases, and technical details listing all files and verification commands.

### 2. Draft & Confirm

**If per-phase:** for each plan phase, draft a ticket:
- **Type**: Task (default); Story if user-facing value
- **Acceptance criteria**: each observable truth from the phase
- **Technical details**: files to create/modify and verification commands from the phase
- **Dependencies**: list blocking ticket titles (resolved to IDs after creation)

Show as table — columns: #, Summary, Type, Story Points, Depends On — then ask the user to confirm, edit, or cancel.

### 3. Create Tickets

1. **Check for duplicates** — launch one `jira-explorer` agent with the drafted ticket summaries and the project key as its research question. Surface any `possible duplicate` matches it reports (and the terms it swept) to the user before proceeding. If it returns a `### Tool Failure`, stop and offer **retry**, **create anyway** (stating that duplicate detection did not run), or **abort** — per `.claude/rules/tool-reliability.md`.
2. **Write the description** — one file per ticket, using this template verbatim:
   ```
   ## Summary
   <1–2 sentence problem statement from the phase goal>

   ## Acceptance Criteria
   - <observable truth 1>
   - <observable truth 2>

   ## Technical Details
   - Files: `<paths>`
   - Verification: `<commands>`

   ## Dependencies
   - <blocking ticket title or "None">

   ## Suggested Priority
   <Critical|High|Medium|Low> — <brief justification>
   ```
   Write it to `.planning/tickets/<n>.md` — the same directory the plan lives in, so drafts stay reviewable and re-runnable. `acli` stores plain text **verbatim**, so a markdown file passed straight through renders as literal `##` and `-` characters in Jira — always convert it first (next step).

   **Stay inside the supported constructs** — headings, `- ` bullets, paragraphs, `` `inline code` ``, and `[label](url)` links. No `**bold**`, `*italic*`, `~~strike~~`, `__underline__`, or raw HTML; wrap file paths, commands, and globs in backticks so `*` characters inside them are treated as literal.

3. **Build the work item payload** — the description becomes ADF, wrapped in the JSON shape `acli` expects:
   ```bash
   python3 .claude/skills/jira/scripts/build-workitem.py .planning/tickets/<n>.md \
     --project <KEY> --type <TYPE> --summary "<SUMMARY>" \
     [--label <l>] [--parent <ID>] [--field customfield_XXXXX=<points>] \
     > .planning/tickets/<n>.json
   ```
   The converter **exits 1 on anything it does not support** rather than emitting a document that renders wrongly — code fences, tables, ordered lists, nested bullets, blockquotes, malformed headings, and the inline markdown listed above.

   Payload keys are exactly those of `acli jira workitem create --generate-json`; only supplied keys are emitted. Use `--adf-only` instead when you need a bare ADF document for `--description-file` (e.g. editing an existing item's description).

   If it exits non-zero, **stop** and offer **fix the description**, **create with plain-text `--description`** (stating that the ticket body will not render), or **abort** — per `.claude/rules/tool-reliability.md`. Never fall back silently.

4. **Create via acli** (or emit the rendered markdown as copy-ready content if unavailable):
   - Run `acli jira workitem create --from-json .planning/tickets/<n>.json`
   - `--from-json` carries the whole work item, so **no other flags are needed** — project, type, summary, description, labels, and parent all come from the file
   - **Story points** need the project's custom field ID, which varies per Jira site. Discover it once with `acli jira workitem view <EXISTING-ID> --fields '*all' --json` — `--json` alone returns only the default field set (`key,issuetype,summary,status,assignee,description`) and shows no custom fields at all. Pass it as `--field customfield_XXXXX=<points>`. If the ID is unknown, **omit points rather than guessing** and tell the user they need setting manually.
   - **`--parent`** maps to acli's `parentIssueId`, which its schema documents as sub-task only. Passing an epic as the parent of a Story or Task is untested — if creation fails on it, retry without `--parent` and tell the user to link the epic in Jira.
   - **Do NOT pass `--priority`** — it is not a valid flag, and priority stays as the "Suggested Priority" section in the description

### 4. Present Manifest

Output the manifest and store it in `.planning/STATE.md` under a `## Tickets` section:

| Ticket ID | Summary | Branch Name |
|-----------|---------|-------------|
| UN-1234 | ... | UN-1234-short-description |
| UN-1235 | ... | UN-1235-short-description |

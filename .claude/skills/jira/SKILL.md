---
name: jira
description: >-
  User asks to "create Jira tickets", "decompose into tickets", "file tickets from plan",
  or mentions "Jira" in context of creating tickets from a plan.
  Requires a plan file path as the first argument (e.g., .planning/STATE.md) — stops if no path is provided.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature).
argument-hint: "<plan-file-path> [PROJECT]"
allowed-tools: Read, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version)
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

ultrathink

Decompose an approved implementation plan into Jira tickets. Reads phases from a user-supplied plan file path and creates one ticket per phase with dependency tracking and execution wave grouping.

## Ticket Philosophy

- **Context from plan** — extract ticket content from the supplied plan file's phases, not from conversation or git history
- **User confirmation** — always present ticket details for review before creating; never file a ticket without explicit approval
- **Template-driven content** — use structured templates for consistent, actionable tickets; every field should be filled or explicitly marked as unknown
- **Graceful degradation** — if acli is unavailable, generate copy-ready content for manual entry rather than failing
- **Duplicate awareness** — search for existing tickets before creating new ones; avoid cluttering the backlog

## Iron Laws

> - NEVER execute `delete` or any destructive/administrative acli command — if requested, refuse and direct the user to manage these directly in Jira
> - NEVER create or modify a ticket without user confirmation
> - NEVER include secrets, credentials, API keys, or connection strings in ticket content
> - NEVER apply bulk `update`, `edit`, or `transition` operations without first listing all affected ticket IDs and getting explicit user confirmation
> - ALWAYS search for duplicates before creating a new ticket
> - ALWAYS use Markdown formatting in ticket descriptions (`##`/`###` headings, `1.` numbered lists, `-` bullets, fenced code blocks)

## Input Handling

Parse `$ARGUMENTS` as: `<plan-file-path> [PROJECT]`.

- The first token that contains a path separator (`/`) or file extension is treated as the plan file path.
- The next token matching only uppercase letters and digits (no slash) is treated as the project key.
- If `<plan-file-path>` is absent → **stop immediately**:
  > "No plan file path provided. Re-run as `/jira <plan-file-path> [PROJECT]` (e.g., `/jira .planning/STATE.md UN`). Run `/plan` first if you do not have a plan file yet."

### Pre-flight

1. **Resolve plan path**: extract `<plan-file-path>` from `$ARGUMENTS`. If absent → stop (see above).
2. **Read plan file**: read the file at the provided path.
   - If the file does not exist → **stop**: "Plan file not found at `<path>`. Verify the path or run `/plan` to create one."
   - If the file exists but contains no `#### Phase` headings → **stop**: "No phases found in `<path>`. Run `/plan` to decompose the goal into phases."
   - If phases exist → proceed to Process.
3. **Resolve project**: second argument if present, else default to `UN`.
4. **Check acli availability**: run `acli --version`; available → create directly via acli; unavailable → generate content for manual entry.

**Stop conditions:**
- No plan file path in `$ARGUMENTS` → stop and prompt user for the path
- Plan file not found or has no phases → stop and direct to `/plan`
- acli authentication failure → prompt user to run `acli jira auth login`

---

## Process

### 1. Load Plan

- Read the plan file at the path provided in `$ARGUMENTS`
- Extract for each phase:
  - **Goal** → ticket summary
  - **Observable truths** → acceptance criteria
  - **Dependencies** → blocking relationships between tickets
  - **Files to create/modify** + **Verification** → technical details

#### Modularity Assessment

After extracting phases, classify each phase:
- **Independent** — `Dependencies` is `None`; can be worked in parallel with other independent phases
- **Dependent** — `Dependencies` lists one or more other phases; must be sequenced after them

Record the classification for each phase. This drives the `Depends On` column and execution wave grouping in Step 2.

**Stop conditions:**
- Plan file has no phases → ask user to run `/plan` to decompose the goal into phases

### 2. Draft Ticket Set

For each plan phase, draft a ticket:
- **Type**: Task (default); use Story if the phase delivers user-facing value
- **Summary**: phase goal (one sentence, imperative)
- **Acceptance criteria**: each observable truth from the phase, formatted as a checklist
- **Technical details**: files to create/modify and verification commands from the phase
- **Dependencies**: list blocking ticket titles (resolved to IDs after creation)
- **Suggested Story Points**: estimate based on phase scope:
  - 1 pt — single file, trivial change
  - 2 pts — 2-4 files, clear implementation path
  - 3 pts — 5+ files or new integration point
  - 5 pts — cross-cutting concern or significant unknowns
  - 8 pts — consider splitting the phase

Present the full ticket set to the user as a table before creating anything. Use the modularity classification from Step 1 to annotate independent tickets:

| # | Summary | Type | Story Points | Depends On |
|---|---------|------|-------------|------------|
| 1 | ... | Task | 3 | — (parallel) |
| 2 | ... | Task | 2 | — (parallel) |
| 3 | ... | Task | 2 | #1 |
| 4 | ... | Story | 3 | #2, #3 |

After the table, present execution waves so the user can see what can be worked in parallel:

> **Execution waves:**
> - Wave 1 (parallel): #1, #2
> - Wave 2: #3 (after #1), #4 (after #2, #3)

Ask the user to confirm, adjust story points, or cancel individual tickets before proceeding.

### 3. Create Tickets

**Only proceed after user approval of the full ticket set.**

For each ticket in dependency order:

1. **Check for duplicates** — search for existing tickets with a similar summary in the same project:
   - Use `acli jira workitem search --jql` with a JQL query targeting the project and keywords from the title
     - Example: `project = UN AND summary ~ "login timeout" ORDER BY created DESC`
   - If similar tickets found → present them to the user and ask whether to proceed with creation or link to an existing ticket
   - If no matches → proceed
2. **Scan content for secrets/PII** — strip or redact any secrets, credentials, API keys, tokens, connection strings, or PII found; ticket content is visible to all project members
3. **Create via acli** (or generate copy-ready content if unavailable):
   - Run `acli jira workitem create --project <KEY> --type <TYPE> --summary "<SUMMARY>" --description "<DESC>"`
   - **Only these four flags are supported** — do NOT pass `--priority` or any other flags
   - Priority is embedded in the description via the template's "Suggested Priority" field; default to Medium if no signal
   - Descriptions must use Markdown format (`##`, `###`, `1.`, `-`, fenced code blocks)
4. **Verify** — fetch the created ticket back using `acli jira workitem view <ISSUE_KEY>` to confirm it exists; if fetch fails, warn the user and suggest checking Jira manually
5. **Record** the ticket ID in the manifest — write it to the plan file (the path supplied in `$ARGUMENTS`) under `## Tickets` immediately after each successful creation (not at the end of the batch), so partial progress is preserved if the batch fails mid-way

**Partial batch failure:** If creation fails after some tickets have already been created, immediately surface a status table: which tickets were created (with IDs), which failed, and which are pending. Record created IDs in the plan file before attempting fallback for remaining tickets.

### 4. Present Manifest

After all tickets are created, output the manifest:

| Ticket ID | Summary | Branch Name |
|-----------|---------|-------------|
| UN-1234 | ... | UN-1234-short-description |
| UN-1235 | ... | UN-1235-short-description |

Store the manifest in the plan file (the path supplied in `$ARGUMENTS`) under a `## Tickets` section for use by `/feature`.

**Workflow reminder:** `/plan` → `/jira` → pick up ticket → `/feature <TICKET-ID>` → `/verify` → `/review` → commit → `/pr`

---

## Output Principles

- **Ticket set preview first** — present the complete batch ticket table for user approval before creation; no surprises
- **Actionable results** — include ticket IDs, URLs, suggested branch names, and workflow next steps after creation
- **Template compliance** — all tickets follow structured templates with required fields filled; incomplete sections noted explicitly
- **Workflow continuity** — connect tickets to downstream workflows: create branch → implement → commit → `/pr`

## Error Handling

| Scenario | Response |
|----------|----------|
| No plan file path in `$ARGUMENTS` | Stop: "Provide a plan file path: `/jira <plan-file-path> [PROJECT]`" |
| Plan file not found at supplied path | Stop: "Plan file not found at `<path>`. Verify the path or run `/plan`." |
| Plan file has no phases | Stop: "No phases in `<path>`. Run `/plan` to decompose the goal." |
| acli not available | Fall back to content generation |
| Authentication error | "Run `acli jira auth login` to authenticate" |
| Unknown project | Prompt for project key |
| API error | Provide content for manual entry |
| Duplicate ticket found | Present existing tickets, ask user to confirm or cancel |
| Verification fetch fails | Warn user, provide ticket ID and suggest checking Jira |
| Forbidden operation requested | Refuse: "Deletion and admin commands are outside this skill's scope — manage these directly in Jira" |

Never create a ticket without user confirmation or skip duplicate checking — surface existing tickets before filing new ones.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Required first step — creates the plan file that you pass to `/jira <plan-file-path>` |
| `/feature` | Pick up a Jira ticket and implement it (`/feature <TICKET-ID>`) |
| `/verify` | Verify implementation completeness after `/feature` |
| `/review` | Code quality review after `/verify` in the delivery chain |
| `/pr` | Create pull request (after commits made) |
| `/confluence` | Create or view Confluence pages (not Jira tickets) |

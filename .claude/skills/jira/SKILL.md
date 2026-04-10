---
name: jira
description: >-
  User asks to "create a Jira ticket", "file a ticket", "create a story",
  or mentions "Jira" in context of creating or searching tickets.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature).
argument-hint: "[PROJECT] [bug|task|story] [title or description]"
allowed-tools: Read, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version)
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

ultrathink

Create Jira tickets from the current conversation context with structured templates. Returns a ticket ID for use in branch creation and downstream workflows.

## Ticket Philosophy

- **Context from conversation** — extract ticket content from the current session discussion, not from git history or guesswork
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

Determine ticket creation intent from `$ARGUMENTS` (evaluated in priority order):

| Priority | Input | Intent | Approach |
|----------|-------|--------|----------|
| 1 | `decompose` / `decompose plan` | Explicit batch decomposition | Steps 1-6 in batch mode; read `.planning/STATE.md`, map phases to tickets |
| 2 | Type keyword (e.g., `bug`, `task`, `story`) | Create typed ticket | Steps 1-6 single-ticket mode; plan is ignored even if it exists |
| 2 | Type + title (e.g., `bug fix login timeout`) | Typed ticket with title | Steps 1-6; skip title inference |
| 2 | Project + type (e.g., `PROJ bug`) | Project-scoped ticket | Steps 1-6; use specified project instead of default UN |
| 2 | Project + type + title (e.g., `PROJ bug fix login`) | Fully specified ticket | Steps 1-6; minimal inference needed |
| 3 | (none / ambiguous) and `.planning/STATE.md` has phases | Auto batch decomposition | Steps 1-6 in batch mode; plan detected automatically |
| 4 | (none / ambiguous) and no plan exists | Infer from conversation | Steps 1-6; emphasis on type resolution (step 1) |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and resolve batch decomposition mode using this priority order:
  1. `$ARGUMENTS` is `decompose` or `decompose plan` → **batch mode**
  2. `$ARGUMENTS` matches a ticket-type keyword (`bug`, `task`, `story`) or includes a project/title → **single-ticket mode** (skip plan check entirely)
  3. `$ARGUMENTS` is absent or ambiguous → check if `.planning/STATE.md` exists and contains at least one `#### Phase` heading → if yes, **batch mode**; otherwise continue to single-ticket flow
- **If batch decomposition mode**: skip to **Batch Decomposition** section below
- Resolve project: user-provided project code from arguments, or default to `UN`
- Resolve ticket type (priority order):
  1. User-provided type (`bug`, `task`, or `story` in arguments)
  2. Conversation keywords: `error, bug, broken, crash, fail, regression, not working` → Bug
  3. Conversation keywords: `user story, as a user, user wants, feature request` → Story
  4. Conversation keywords: `implement, refactor, update, configure, task, add, create` → Task
  5. Cannot determine → Ask user
- Check acli availability: run `acli --version`; acli available → create directly via acli; acli unavailable → generate content for manual entry

**Stop conditions:**
- Unclear ticket type and cannot infer from conversation → ask user to clarify (bug, task, or story)
- No meaningful conversation context and no title provided → prompt user to describe the issue or task

---

## Batch Decomposition Mode

Triggered automatically when `.planning/STATE.md` contains phases and no explicit ticket-type argument was provided, or explicitly via `decompose` / `decompose plan`. Reads an approved plan and creates one Jira ticket per phase, with modularity-aware grouping.

### BD-1. Load Plan

- Read `.planning/STATE.md` (or ask the user for the plan file path if not found)
- Extract for each phase:
  - **Goal** → ticket summary
  - **Observable truths** → acceptance criteria
  - **Dependencies** → blocking relationships between tickets
  - **Files to create/modify** + **Verification** → technical details

#### Modularity Assessment

After extracting phases, classify each phase:
- **Independent** — `Dependencies` is `None`; can be worked in parallel with other independent phases
- **Dependent** — `Dependencies` lists one or more other phases; must be sequenced after them

Record the classification for each phase. This drives the `Depends On` column and execution wave grouping in BD-2.

**Stop conditions:**
- No plan file found and user cannot provide one → redirect to `/plan` first
- Plan has no phases → ask user to run `/plan` to decompose the goal into phases

### BD-2. Draft Ticket Set

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

Present the full ticket set to the user as a table before creating anything. Use the modularity classification from BD-1 to annotate independent tickets:

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

### BD-3. Create Tickets Sequentially

**Only proceed after user approval of the full ticket set.**

For each ticket in dependency order:
1. Check for duplicates (Step 2 of normal flow)
2. Scan content for secrets/PII
3. Create via acli (or generate copy-ready content if unavailable)
4. Verify the ticket was created by fetching it back
5. Record the ticket ID in a manifest

After all tickets are created, output the manifest:

| Ticket ID | Summary | Branch Name |
|-----------|---------|-------------|
| UN-1234 | ... | UN-1234-short-description |
| UN-1235 | ... | UN-1235-short-description |

Store the manifest in `.planning/STATE.md` under a `## Tickets` section for use by `/feature`.

---

### 2. Check for Duplicates

Before gathering content, search for existing tickets with a similar summary in the same project:

- Use `acli jira workitem search --jql` with a JQL query targeting the project and keywords from the title
  - Example: `project = UN AND summary ~ "login timeout" ORDER BY created DESC`
- If similar tickets found → Present them to the user and ask whether to proceed with creation or link to an existing ticket
- If no matches → Proceed to content gathering

### 3. Gather Content from Conversation

Summarize from the current session — do NOT use git history for content:
- **What problem or need was identified** (becomes the description)
- **What was investigated or discussed** (becomes background/steps)
- **What solution or approach was determined** (becomes technical details/acceptance criteria)
- **Any error messages or logs shared** (included verbatim for bugs)

Apply the appropriate template from `@references/templates.md`. Story tickets use the Task template.

**Priority mapping** — use conversation signals to suggest a priority level (for the ticket description's "Suggested Priority" field, NOT for a CLI flag):

| Conversation Signal | Suggested Priority |
|---|---|
| `critical, blocker, production down, outage` | Critical |
| `urgent, important, breaking, security` | High |
| `should, want, improve, enhance` | Medium |
| `nice to have, low priority, minor, cosmetic` | Low |

If no clear signal, default to Medium.

### 4. Confirm with User

Before presenting the summary, scan the drafted content for secrets, credentials, API keys, tokens, connection strings, and PII — strip or redact any found, as ticket content is visible to all project members.

Present a summary of the ticket details:
- **Project**: The project key (e.g., UN)
- **Type**: Bug, Task, or Story
- **Title**: The ticket summary
- **Priority**: Suggested priority with justification
- **Description**: Preview of the content (first few lines or key sections)

Ask the user to confirm before creating the ticket. This prevents incorrect tickets from being filed.

### 5. Create Ticket

- **acli available**: Run `acli jira workitem create --project <KEY> --type <TYPE> --summary "<SUMMARY>" --description "<DESC>"`
  - **Only these four flags are supported** — do NOT pass `--priority` or any other flags
  - Priority is already embedded in the description via the template's "Suggested Priority" field
  - Descriptions must use Markdown format (##, ###, 1., -, fenced code blocks)
- **acli unavailable**: Generate copy-ready formatted content for manual entry

### 6. Verify and Present Result

**Verification** (acli only):
- Fetch the created ticket back using `acli jira workitem view <ISSUE_KEY>` to confirm it exists
- If fetch fails, warn the user and suggest checking Jira manually

**Show the user:**
- **Ticket ID** and URL: derive the Atlassian base URL from `acli` config if possible, otherwise use `https://qredab.atlassian.net/browse/<TICKET-ID>`
- **Type**, **priority**, and **summary**
- **Suggested branch name**: `<TICKET-ID>-<short-description>` (e.g., `UN-1234-fix-login-timeout`)
- **Workflow reminder**: `/plan` → `/jira` (auto-decomposes if plan exists) → pick up ticket → `/feature <TICKET-ID>` → `/verify` → `/review` → commit → `/pr`

## Output Principles

- **Ticket preview first** — present the complete ticket summary for user approval before creation; no surprises
- **Actionable results** — include ticket ID, URL, suggested branch name, and workflow next steps after creation
- **Template compliance** — all tickets follow structured templates with required fields filled; incomplete sections noted explicitly
- **Workflow continuity** — connect the ticket to downstream workflows: create branch → implement → commit → `/pr`

## Error Handling

| Scenario | Response |
|----------|----------|
| acli not available | Fall back to content generation |
| Authentication error | "Run `acli jira auth login` to authenticate" |
| Unknown project | Prompt for project key |
| API error | Provide content for manual entry |
| No conversation context | Prompt user to describe the issue or task |
| Duplicate ticket found | Present existing tickets, ask user to confirm or cancel |
| Verification fetch fails | Warn user, provide ticket ID and suggest checking Jira |
| Forbidden operation requested | Refuse: "Deletion and admin commands are outside this skill's scope — manage these directly in Jira" |

Never create a ticket without user confirmation or skip duplicate checking — surface existing tickets before filing new ones.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Create an implementation plan before decomposing into tickets |
| `/feature` | Pick up a Jira ticket and implement it (`/feature <TICKET-ID>`) |
| `/pr` | Create pull request (after commits made) |
| `/confluence` | Create or view Confluence pages (not Jira tickets) |

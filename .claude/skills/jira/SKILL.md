---
name: jira
description: >-
  User asks to "create a Jira ticket", "file a ticket", "create a story",
  or mentions "Jira" in context of creating or searching tickets.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature).
argument-hint: "[PROJECT] [bug|task|story] [title or description]"
allowed-tools: Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version)
disable-model-invocation: true
---

Create Jira tickets from the current conversation context with structured templates. Returns a ticket ID for use in branch creation and downstream workflows.

## Ticket Philosophy

- **Context from conversation** — extract ticket content from the current session discussion, not from git history or guesswork
- **User confirmation** — always present ticket details for review before creating; never file a ticket without explicit approval
- **Template-driven content** — use structured templates for consistent, actionable tickets; every field should be filled or explicitly marked as unknown
- **Graceful degradation** — if acli is unavailable, generate copy-ready content for manual entry rather than failing
- **Duplicate awareness** — search for existing tickets before creating new ones; avoid cluttering the backlog

## Guardrails

This skill is scoped to **read and modify** operations — never destructive or administrative commands. The following rules apply to all acli usage:

**Allowed actions**: `search`, `view`, `create`, `update`, `edit`, `transition`

**Forbidden actions**: `delete` and any other destructive or administrative commands. If a user requests ticket deletion, refuse and explain that deletion is outside this skill's scope — they should delete tickets directly in Jira.

**Multi-ticket confirmation**: When an `update`, `edit`, or `transition` would affect multiple tickets, list all affected ticket IDs and ask the user to explicitly confirm before proceeding.

**Sensitive data exclusion**: Before creating or updating a ticket, scan the drafted content for secrets, credentials, API keys, tokens, connection strings, and PII. Strip or redact any sensitive values — ticket content is visible to all project members.

**Description formatting**: All ticket descriptions must use Markdown formatting. Use `##` / `###` for headings, `1.` for numbered lists, `-` for bullet lists, and fenced code blocks. The templates in `@references/templates.md` use the correct format.

## Iron Laws

> - NEVER execute `delete` or any destructive/administrative acli command
> - NEVER create or modify a ticket without user confirmation
> - NEVER include secrets, credentials, API keys, or connection strings in ticket content
> - ALWAYS search for duplicates before creating a new ticket
> - ALWAYS use Markdown formatting in ticket descriptions

## Input Handling

Determine ticket creation intent from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| Type keyword (e.g., `bug`, `task`, `story`) | Create typed ticket | Steps 1-6; apply template for specified type from `@references/templates.md` |
| Type + title (e.g., `bug fix login timeout`) | Typed ticket with title | Steps 1-6; skip title inference |
| Project + type (e.g., `PROJ bug`) | Project-scoped ticket | Steps 1-6; use specified project instead of default UN |
| Project + type + title (e.g., `PROJ bug fix login`) | Fully specified ticket | Steps 1-6; minimal inference needed |
| (none / ambiguous) | Infer from conversation | Steps 1-6; emphasis on type resolution (step 1) |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent (Type Keyword, Type + Title, Project + Type, Project + Type + Title, or Infer from Conversation) using the Input Handling table
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
- **Ticket ID** and URL: `https://qredab.atlassian.net/browse/<TICKET-ID>`
- **Type**, **priority**, and **summary**
- **Suggested branch name**: `<TICKET-ID>-<short-description>` (e.g., `UN-1234-fix-login-timeout`)
- **Workflow reminder**: Create branch → implement → `/commit` → `/pr`

## Output Principles

- **Ticket preview first** — present the complete ticket summary for user approval before creation; no surprises
- **Actionable results** — include ticket ID, URL, suggested branch name, and workflow next steps after creation
- **Template compliance** — all tickets follow structured templates with required fields filled; incomplete sections noted explicitly
- **Workflow continuity** — connect the ticket to downstream workflows: create branch → implement → `/commit` → `/pr`

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
| `/feature` | Implement feature after ticket is created |
| `/commit` | Commit with ticket reference (after branch created) |
| `/pr` | Create pull request (after commits made) |

---
name: jira
description: Use when the user asks to "create a Jira ticket", "file a bug", "add a task", "create an issue", mentions "Jira", "JIRA", or "ticket".
argument-hint: "[PROJECT] [bug|task|story] [title or description] [--assignee <user>]"
disable-model-invocation: true
allowed-tools: mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__createJiraIssue, mcp__atlassian__lookupJiraAccountId, mcp__atlassian__getJiraIssue
---

Create Jira tickets from the current conversation context with structured templates. Returns a ticket ID for use in branch creation and downstream workflows.

## Ticket Philosophy

- **Context from conversation** — extract ticket content from the current session discussion, not from git history or guesswork
- **User confirmation** — always present ticket details for review before creating; never file a ticket without explicit approval
- **Template-driven content** — use structured templates for consistent, actionable tickets; every field should be filled or explicitly marked as unknown
- **Graceful degradation** — if MCP is unavailable, generate copy-ready content for manual entry rather than failing
- **Duplicate awareness** — search for existing tickets before creating new ones; avoid cluttering the backlog

## When to Use

### This Skill Is For

- Creating bug reports from issues discovered during a session
- Creating task tickets from work identified in conversation
- Creating story tickets from user-facing feature requests
- Filing issues with context from the current discussion (problem, investigation, solution)

### Use a Different Approach When

- Planning a feature first → use `/feature`
- Creating a PR after implementation → use `/pr`
- Committing changes with ticket reference → use `/commit`

## Input Classification

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

- Parse `$ARGUMENTS` and map to the appropriate intent (Type Keyword, Type + Title, Project + Type, Project + Type + Title, or Infer from Conversation) using the Input Classification table
- Resolve project: user-provided project code from arguments, or default to `UN`
- Resolve ticket type (priority order):
  1. User-provided type (`bug`, `task`, or `story` in arguments)
  2. Conversation keywords: `error, bug, broken, crash, fail, regression, not working` → Bug
  3. Conversation keywords: `user story, as a user, user wants, feature request` → Story
  4. Conversation keywords: `implement, refactor, update, configure, task, add, create` → Task
  5. Cannot determine → Ask user
- Check MCP availability: MCP available → create directly via Atlassian MCP; MCP unavailable → generate content for manual entry

**Stop conditions:**
- Unclear ticket type and cannot infer from conversation → ask user to clarify (bug, task, or story)
- No meaningful conversation context and no title provided → prompt user to describe the issue or task

### 2. Check for Duplicates

Before gathering content, search for existing tickets with a similar summary in the same project:

- Use `mcp__atlassian__searchJiraIssuesUsingJql` with a JQL query targeting the project and keywords from the title
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

**Priority mapping** — use conversation signals to suggest a priority level:

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
- **Assignee**: If `--assignee` provided
- **Description**: Preview of the content (first few lines or key sections)

Ask the user to confirm before creating the ticket. This prevents incorrect tickets from being filed.

### 5. Create Ticket

- **MCP available**: Call `mcp__atlassian__createJiraIssue` with project key, issue type, summary, and formatted description
  - If `--assignee` provided, use `mcp__atlassian__lookupJiraAccountId` to resolve the user, then include the assignee in the creation call
- **MCP unavailable**: Generate copy-ready formatted content for manual entry

### 6. Verify and Present Result

**Verification** (MCP only):
- Fetch the created ticket back using `mcp__atlassian__getJiraIssue` to confirm it exists
- If fetch fails, warn the user and suggest checking Jira manually

**Show the user:**
- **Ticket ID** and canonical URL (if MCP)
- **Type**, **priority**, and **summary**
- **Assignee** (if set)
- **Suggested branch name**: `<TICKET-ID>-<short-description>` (e.g., `UN-1234-fix-login-timeout`)
- **Workflow reminder**: Create branch → implement → `/commit` → `/pr`

## Output Principles

- **Ticket preview first** — present the complete ticket summary for user approval before creation; no surprises
- **Actionable results** — include ticket ID, URL, suggested branch name, and workflow next steps after creation
- **Template compliance** — all tickets follow structured templates with required fields filled; incomplete sections noted explicitly
- **Workflow continuity** — connect the ticket to downstream workflows: create branch → implement → `/commit` → `/pr`

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Use `UN` project, infer type from conversation |
| Type keyword (`bug`, `task`, `story`) | Use `UN` project with specified type |
| Type + title (`bug fix login timeout`) | Use `UN` project with specified type and title |
| Project + type (`PROJ bug`) | Use specified project with type |
| Project + type + title (`PROJ bug fix login`) | Use specified project with type and title |

**Modifiers:** `--assignee <user>` can appear anywhere in arguments to assign the ticket. A leading all-caps token before `bug`/`task`/`story` (matching `[A-Z]+`) is treated as a project override.

## Error Handling

| Scenario | Response |
|----------|----------|
| MCP not available | Fall back to content generation |
| Authentication error | "Configure Atlassian MCP credentials" |
| Unknown project | Prompt for project key |
| API error | Provide content for manual entry |
| No conversation context | Prompt user to describe the issue or task |
| Duplicate ticket found | Present existing tickets, ask user to confirm or cancel |
| Assignee not found | Warn user, create ticket without assignee |
| Verification fetch fails | Warn user, provide ticket ID and suggest checking Jira |

Never create a ticket without user confirmation or skip duplicate checking — surface existing tickets before filing new ones.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/commit` | Commit with ticket reference (after branch created) |
| `/pr` | Create pull request (after commits made) |
| `/explore` | Understand codebase before filing a ticket |

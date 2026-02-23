---
name: jira
description: Use when the user asks to "create a Jira ticket", "file a bug", "add a task", "create an issue", mentions "Jira", "JIRA", "ticket", or needs to create issue tracker tickets.
argument-hint: "[PROJECT] [bug|task|story] [title or description] [--assignee <user>]"
disable-model-invocation: true
---

Create Jira tickets from the current conversation context with structured templates. Returns a ticket ID for use in branch creation and downstream workflows.

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

## Process

### 1. Pre-flight Checks

**Check MCP availability:**
- MCP available → Create ticket directly via Atlassian MCP
- MCP unavailable → Generate formatted content for manual entry

**Stop conditions:**
- Unclear ticket type and cannot infer from conversation → Ask user to clarify (bug, task, or story)
- No meaningful conversation context and no title provided → Prompt user to describe the issue or task

### 2. Resolve Project and Type

**Project** (priority order):
1. User-provided project code in arguments (`/jira PROJ bug title`)
2. Default: `UN`

**Ticket type** (priority order):
1. User-provided type (`/jira bug`, `/jira task`, or `/jira story`)
2. Conversation keywords: `error, bug, broken, crash, fail, regression, not working` → Bug
3. Conversation keywords: `user story, as a user, user wants, feature request` → Story
4. Conversation keywords: `implement, refactor, update, configure, task, add, create` → Task
5. Cannot determine → Ask user

### 3. Check for Duplicates

Before gathering content, search for existing tickets with a similar summary in the same project:

- Use `mcp__atlassian__searchJiraIssuesUsingJql` with a JQL query targeting the project and keywords from the title
  - Example: `project = UN AND summary ~ "login timeout" ORDER BY created DESC`
- If similar tickets found → Present them to the user and ask whether to proceed with creation or link to an existing ticket
- If no matches → Proceed to content gathering

### 4. Gather Content from Conversation

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

### 5. Confirm with User

Present a summary of the ticket details:
- **Project**: The project key (e.g., UN)
- **Type**: Bug, Task, or Story
- **Title**: The ticket summary
- **Priority**: Suggested priority with justification
- **Assignee**: If `--assignee` provided
- **Description**: Preview of the content (first few lines or key sections)

Ask the user to confirm before creating the ticket. This prevents incorrect tickets from being filed.

### 6. Create Ticket

- **MCP available**: Call `mcp__atlassian__createJiraIssue` with project key, issue type, summary, and formatted description
  - If `--assignee` provided, use `mcp__atlassian__lookupJiraAccountId` to resolve the user, then include the assignee in the creation call
- **MCP unavailable**: Generate copy-ready formatted content for manual entry

### 7. Verify and Present Result

**Verification** (MCP only):
- Fetch the created ticket back using `mcp__atlassian__getJiraIssue` to confirm it exists
- If fetch fails, warn the user and suggest checking Jira manually

**Show the user:**
- **Ticket ID** and canonical URL (if MCP)
- **Type**, **priority**, and **summary**
- **Assignee** (if set)
- **Suggested branch name**: `<TICKET-ID>-<short-description>` (e.g., `UN-1234-fix-login-timeout`)
- **Workflow reminder**: Create branch → implement → `/commit` → `/pr`

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Use `UN` project, infer type from conversation |
| `bug` / `task` / `story` | Use `UN` project with specified type |
| `bug <title>` / `task <title>` / `story <title>` | Use `UN` project with type and title |
| `PROJ bug` / `PROJ task` / `PROJ story` | Use specified project with type |
| `PROJ bug <title>` / `PROJ task <title>` / `PROJ story <title>` | Use specified project with type and title |
| `--assignee <user>` | Assign ticket to specified user |

**Argument parsing**: A leading all-caps token before `bug`/`task`/`story` (matching `[A-Z]+`) is treated as a project override. The `--assignee` flag can appear anywhere in the arguments.

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

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/commit` | Commit with ticket reference (after branch created) |
| `/pr` | Create pull request (after commits made) |

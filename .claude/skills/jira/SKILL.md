---
name: jira
description: Use when the user asks to "create a Jira ticket", "file a bug", "add a task", "create an issue", mentions "Jira", "JIRA", "ticket", or needs to create issue tracker tickets.
argument-hint: "[PROJECT] [bug|task] [title or description]"
disable-model-invocation: true
allowed-tools: mcp__atlassian__createJiraIssue, mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__getVisibleJiraProjects, mcp__atlassian__getJiraProjectIssueTypesMetadata
---

Create Jira tickets from the current conversation context with structured templates. Returns a ticket ID for use in branch creation and downstream workflows.

## When to Use

### This Skill Is For

- Creating bug reports from issues discovered during a session
- Creating task tickets from work identified in conversation
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
- Unclear ticket type and cannot infer from conversation → Ask user to clarify (bug or task)
- No meaningful conversation context and no title provided → Prompt user to describe the issue or task

### 2. Resolve Project and Type

**Project** (priority order):
1. User-provided project code in arguments (`/jira PROJ bug title`)
2. Default: `UN`

**Ticket type** (priority order):
1. User-provided type (`/jira bug` or `/jira task`)
2. Conversation keywords: `error, bug, broken, crash, fail, regression, not working` → Bug
3. Conversation keywords: `implement, refactor, update, configure, task, add, create` → Task
4. Cannot determine → Ask user

### 3. Gather Content from Conversation

Summarize from the current session — do NOT use git history for content:
- **What problem or need was identified** (becomes the description)
- **What was investigated or discussed** (becomes background/steps)
- **What solution or approach was determined** (becomes technical details/acceptance criteria)
- **Any error messages or logs shared** (included verbatim for bugs)

Apply the appropriate template from `@references/templates.md`.

### 4. Confirm with User

Present a summary of the ticket details:
- **Project**: The project key (e.g., UN)
- **Type**: Bug or Task
- **Title**: The ticket summary
- **Description**: Preview of the content (first few lines or key sections)

Ask the user to confirm before creating the ticket. This prevents incorrect tickets from being filed.

### 5. Create Ticket

- **MCP available**: Call `mcp__atlassian__createJiraIssue` with project key, issue type, summary, and formatted description
- **MCP unavailable**: Generate copy-ready formatted content for manual entry

### 6. Present Result and Next Steps

Show the user:
- **Ticket ID** and URL (if MCP)
- **Type** and **summary**
- **Suggested branch name**: `<TICKET-ID>-<short-description>` (e.g., `UN-1234-fix-login-timeout`)
- **Workflow reminder**: Create branch → implement → `/commit` → `/pr`

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Use `UN` project, infer type from conversation |
| `bug` / `task` | Use `UN` project with specified type |
| `bug <title>` / `task <title>` | Use `UN` project with type and title |
| `PROJ bug` / `PROJ task` | Use specified project with type |
| `PROJ bug <title>` / `PROJ task <title>` | Use specified project with type and title |

**Argument parsing**: A leading all-caps token before `bug`/`task` (matching `[A-Z]+`) is treated as a project override.

## Error Handling

| Scenario | Response |
|----------|----------|
| MCP not available | Fall back to content generation |
| Authentication error | "Configure Atlassian MCP credentials" |
| Unknown project | Prompt for project key |
| API error | Provide content for manual entry |
| No conversation context | Prompt user to describe the issue or task |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/commit` | Commit with ticket reference (after branch created) |
| `/pr` | Create pull request (after commits made) |

---
name: jira
description: Use when the user asks to "create a Jira ticket", "file a bug", "add a task", "create an issue", mentions "Jira", "JIRA", "ticket", or needs to create issue tracker tickets.
argument-hint: "[bug|task] [title or description]"
disable-model-invocation: true
---

Create Jira tickets with intelligent context gathering from git history and structured templates.

## When to Use

### This Skill Is For

- Creating bug reports with reproduction steps
- Creating task tickets with implementation details
- Filing issues with context from current branch/commits

### Use a Different Approach When

- Planning a feature first → use `/feature`
- Creating a PR after implementation → use `/pr`
- Committing changes with ticket reference → use `/commit`

## Process

### 1. Pre-flight Checks

```bash
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
COMMITS=$(git log origin/main..HEAD --pretty=format:"- %s" 2>/dev/null | head -5)
DIFF_STAT=$(git diff --stat HEAD~5..HEAD 2>/dev/null | tail -1)
```

**Check MCP availability:**
- MCP available → Create ticket directly via Atlassian MCP
- MCP unavailable → Generate formatted content for manual entry

**Stop conditions:**
- Unclear ticket type → Ask user to clarify (bug or task)
- Missing required fields → Prompt for specific information

### 2. Classify, Generate, and Create

Use `$ARGUMENTS` if provided (handles ticket type and/or title).

**Classify ticket type** (priority order):
1. User-provided type (`/jira bug` or `/jira task`)
2. Keywords: `error, bug, broken, crash, fail, regression, not working` → Bug
3. Keywords: `implement, refactor, update, configure, task, add, create` → Task
4. Context clues from git history (commit types, diff patterns)

**Generate content** — Apply template from `@references/templates.md`:
- **Bug**: Steps to reproduce, expected/actual behavior, error messages
- **Task**: Requirements, acceptance criteria, technical approach, dependencies

**Create ticket:**
- **MCP available**: Call `mcp__atlassian__create_issue` with project key (from branch or ask), issue type, summary, and formatted description
- **MCP unavailable**: Generate copy-ready formatted content for manual entry

Show the user: ticket key/URL (if MCP), type, summary, and next steps.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Analyze context, ask for type |
| `bug` / `task` | Create with specified type |
| `bug <title>` / `task <title>` | Create with type and title |

## Error Handling

| Scenario | Response |
|----------|----------|
| MCP not available | Fall back to content generation |
| Authentication error | "Configure Atlassian MCP credentials" |
| Unknown project | Prompt for project key |
| API error | Provide content for manual entry |
| No git context | Proceed with user input only |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/pr` | Create PR after implementing ticket |
| `/commit` | Commit with ticket reference |

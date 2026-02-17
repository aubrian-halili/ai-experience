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

## Input Classification

| Keywords | Inferred Type |
|----------|--------------|
| error, bug, broken, crash, fail, regression, not working | Bug |
| implement, refactor, update, configure, task, add, create | Task |

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

### 2. Classify Ticket Type

If not explicitly specified, infer from:
1. User's argument (`/jira bug` or `/jira task`)
2. Keywords in description
3. Context clues from git history

### 3. Generate Content

Apply template from `@references/templates.md`:
- **Bug**: Steps to reproduce, expected/actual behavior, environment
- **Task**: Implementation details, acceptance criteria, dependencies

### 4. Create Ticket

**MCP available:**
```
mcp__atlassian__create_issue with:
- Project key (from branch or ask user)
- Issue type (Bug/Task)
- Summary (title)
- Description (formatted content)
```

**MCP unavailable:**
Generate copy-ready content for manual entry.

## Response Format

```markdown
## Jira Ticket [Created | Content]

**Key**: PROJECT-123 (or "Manual entry required")
**Type**: Bug | Task
**Summary**: [Ticket title]
**URL**: https://company.atlassian.net/browse/PROJECT-123

### Description Preview
[First 200 chars...]

### Context Used
- Branch: `UN-1234-feature-name`
- Commits: 3 analyzed
- Files: 5 changed

### Next Steps
1. [Add details | Copy to Jira]
2. Set assignee and sprint
3. Link related tickets

Reference in commits: `git commit -m "PROJECT-123 feat: description"`
```

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Analyze context, ask for type |
| `bug` / `task` | Create with specified type |
| `bug <title>` / `task <title>` | Create with type and title |

**Examples:**
- `/jira` → Gather context, ask for details
- `/jira bug Login fails on mobile` → Create bug with title
- `/jira task Implement API caching` → Create task with title

## Error Handling

| Scenario | Response |
|----------|----------|
| MCP not available | Fall back to content generation |
| Authentication error | "Configure Atlassian MCP credentials" |
| Unknown project | Prompt for project key |
| Unclear ticket type | Ask: "Bug or task?" |
| API error | Provide content for manual entry |
| No git context | Proceed with user input only |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/pr` | Create PR after implementing ticket |
| `/commit` | Commit with ticket reference |

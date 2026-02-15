---
name: jira
description: Use when the user asks to "create a Jira ticket", "file a bug", "add a task", "create an issue", mentions "Jira", "JIRA", "ticket", or needs to create issue tracker tickets.
argument-hint: "[bug|task] [title or description]"
---

Create Jira tickets with intelligent context gathering from git history, code changes, and structured templates.

## When to Use

### This Skill Is For

- Creating bug reports with reproduction steps
- Creating task tickets with implementation details
- Filing issues with context from current branch/commits
- Generating structured ticket content from code context

### Use a Different Approach When

- Planning a feature first → use `/feature`
- Creating a PR after implementation → use `/pr`
- Committing changes with ticket reference → use `/commit`

## Input Classification

| Keywords | Inferred Type |
|----------|--------------|
| error, bug, broken, crash, fail, regression, issue, not working | Bug |
| implement, refactor, update, configure, setup, task, todo, add, create | Task |

## Process

### 1. Pre-flight Checks

Verify Atlassian MCP availability:

```
Check for mcp__atlassian__ tools in available tools
```

**Modes:**
- **MCP Available**: Create ticket directly via Atlassian MCP
- **MCP Unavailable**: Generate formatted content for manual entry

### 2. Gather Context

Extract context from multiple sources:

```bash
# Get current branch name (may contain ticket reference or feature name)
git branch --show-current

# Get recent commits on this branch
git log origin/main..HEAD --oneline 2>/dev/null || git log -5 --oneline

# Get summary of changes
git diff --stat HEAD~5..HEAD 2>/dev/null || git diff --stat

# Get commit messages for context
git log origin/main..HEAD --pretty=format:"- %s" 2>/dev/null || git log -5 --pretty=format:"- %s"
```

**Context sources:**
- User input (title, description, type)
- Branch name (feature context, existing ticket references)
- Recent commits (what work has been done)
- Code diff (what files changed)
- Error messages (if provided for bugs)

### 3. Classify Ticket Type

If not explicitly specified, infer from:

1. User's argument (e.g., `/jira bug` or `/jira task`)
2. Keywords in description
3. Context clues from git history

**Classification rules:**
- Contains error/bug keywords → Bug
- Contains implementation keywords → Task
- Unclear → Ask user to clarify

### 4. Generate Content

Apply the appropriate template from `references/templates.md`:

- **Bug**: Steps to reproduce, expected/actual behavior, environment, severity
- **Task**: Implementation details, acceptance criteria, dependencies

### 5. Create Ticket

**If Atlassian MCP is available:**

```
Use mcp__atlassian__create_issue or equivalent tool with:
- Project key (from user or configuration)
- Issue type (Bug or Task)
- Summary (title)
- Description (formatted content)
- Priority (if determinable)
- Labels (if applicable)
```

**If MCP is unavailable:**

Generate formatted output for manual entry with copy-ready content.

## Response Format

### MCP Mode (Ticket Created)

```markdown
## Jira Ticket Created

**Key**: PROJECT-123
**Type**: Bug | Task
**Summary**: [Ticket title]
**URL**: https://company.atlassian.net/browse/PROJECT-123

### Description Preview

[First 200 chars of description...]

### Context Used

| Source | Value |
|--------|-------|
| Branch | `feature/user-auth` |
| Commits | 3 commits analyzed |
| Files Changed | 5 files |

### Next Steps

1. Add additional details if needed
2. Set assignee and sprint
3. Link related tickets

---

Reference this ticket in commits: `git commit -m "feat: implement feature [PROJECT-123]"`
```

### Manual Mode (Content Generated)

```markdown
## Jira Ticket Content

**Suggested Type**: Bug | Task
**Suggested Title**: [Inferred title]

> Copy the content below into Jira

---

### Summary

[Ticket title]

### Description

[Full formatted description from template]

---

### Metadata Suggestions

| Field | Suggested Value |
|-------|-----------------|
| Type | Bug / Task |
| Priority | Medium |
| Labels | `backend`, `auth` |

### Git Context

| Info | Value |
|------|-------|
| Branch | `feature/user-auth` |
| Recent Commits | [commit summaries] |

---

After creating the ticket, reference it in commits:
`git commit -m "feat: implement feature [TICKET-ID]"`
```

## Error Handling

| Scenario | Response |
|----------|----------|
| MCP not available | Fall back to content generation mode |
| Authentication error | Guide user: "Configure Atlassian MCP credentials. Check MCP server settings." |
| Unknown project | List available projects or prompt: "Which project should this ticket be created in?" |
| Unclear ticket type | Ask: "Is this a bug report or a task? I detected keywords suggesting [type]." |
| Missing required fields | Prompt for specific information needed |
| API error | Show error details, provide content for manual entry as fallback |
| No git context | Proceed with user-provided information only |

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Analyze context, ask clarifying questions |
| `bug` | Create bug ticket with bug template |
| `task` | Create task ticket with task template |
| `bug <title>` | Create bug with specified title |
| `task <title>` | Create task with specified title |
| `"<description>"` | Infer type from description, use as basis |

**Examples:**
- `/jira` → Gather context, ask for type and details
- `/jira bug` → Create bug ticket, gather context
- `/jira task` → Create task ticket, gather context
- `/jira bug Authentication fails on mobile` → Create bug with title
- `/jira "Implement caching for API responses"` → Infer Task, use as title
- `/jira "Login button not working"` → Infer Bug, use as title

## Project Configuration

If project key is not specified, check for:

1. Environment variable or MCP configuration
2. Recent tickets in git commit messages (e.g., `PROJECT-123`)
3. Ask user to specify project

Extract from commit messages:
```bash
# Find ticket references in recent commits
git log -20 --oneline | grep -oE '[A-Z]+-[0-9]+' | head -1
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan feature before creating ticket |
| `/pr` | Create PR after implementing ticket |
| `/commit` | Commit with ticket reference |
| `/explore` | Understand codebase before filing ticket |

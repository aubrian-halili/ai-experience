---
name: feature
description: Use when the user asks to "implement a feature", "add new functionality", "build this feature", "feature development", mentions "user story", "feature spec", or needs structured feature planning and incremental implementation guidance.
argument-hint: "[feature name or description]"
allowed-tools: Read, Grep, Glob, Write
---

Guide structured feature development from specification through incremental implementation with clear milestones and verification steps.

## Development Philosophy

1. **Incremental delivery** — Ship working slices, not layers; each milestone produces demonstrable value
2. **Specification before code** — Clarify scope, acceptance criteria, and non-scope before writing implementation
3. **User approval gates** — Present plans for review before implementation; never proceed on assumptions
4. **Test-driven confidence** — Write tests first to encode expectations, then implement to satisfy them
5. **Scope discipline** — Build exactly what's needed; track out-of-scope items explicitly and defer them

## When to Use

### This Skill Is For

- Planning and implementing new features
- Breaking down features into incremental deliverables
- Creating feature specifications and acceptance criteria
- Guiding test-driven development for features
- Managing feature scope and dependencies

### Use a Different Approach When

- Fixing a bug → address directly or use `/review` to understand the issue
- Refactoring without new functionality → use `/clean-code`
- High-level architecture decisions → use `/architecture`
- Understanding existing features → use `/explore`

## Input Classification

| Type | Indicators | Approach |
|------|-----------|----------|
| **Greenfield** | "new feature", "add capability" | Full specification + implementation |
| **Enhancement** | "improve", "extend", "add to existing" | Impact analysis + incremental change |
| **Integration** | "connect", "integrate with" | Interface design + compatibility check |
| **Migration** | "replace", "upgrade" | Parallel implementation + switchover |

## Process

### 1. Pre-flight

- Determine feature type from `$ARGUMENTS` using the Input Classification table
- Search for related existing features, patterns, and conventions in the codebase
- Check for existing specs or documentation related to the feature

**Stop conditions:**
- No `$ARGUMENTS` provided → ask user what feature to develop
- Feature already exists → report existing implementation and ask whether to enhance or replace
- Requirements unclear or contradictory → ask clarifying questions before proceeding
- Scope too vague to classify (e.g., "make it better") → ask user to narrow scope

### 2. Specify

- Gather requirements: problem statement, user stories, acceptance criteria, out-of-scope items, and dependencies
- Identify non-functional requirements (performance, security, scalability)
- Analyze the codebase for existing patterns to follow, code to modify vs. create, integration points, and test coverage requirements

### 3. Design & Present

- Break down into incremental milestones with: goal, tasks, dependencies, and verification criteria
- Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
- **Present the complete plan to the user before proceeding to implementation**
- Show: feature specification, milestone breakdown, files to create/modify
- If changes requested, revise and present again

### 4. Implement

**Only proceed after user approval of the plan.**

For each milestone:
1. Write tests first encoding the acceptance criteria (TDD)
2. Implement minimum viable code to pass the tests
3. Verify against the milestone's verification criteria
4. Commit with clear message following project conventions

### 5. Verify

- Confirm all acceptance criteria from the specification are met
- Verify all tests pass and cover key behaviors
- Check that implementation follows existing codebase patterns identified in Pre-flight
- Note any deferred items or out-of-scope work for follow-up
- If feature warrants it, recommend `/review` for formal code review

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what feature to develop |
| Feature name (e.g., `user authentication`) | Full feature workflow for the named feature |
| Feature + scope (e.g., `add OAuth to login`) | Enhancement workflow focused on the specified scope |
| User story (e.g., `as a user I want...`) | Extract requirements from the story, proceed with specification |
| File path (e.g., `src/auth/`) | Scope the feature to the specified module, analyze existing code first |

## Error Handling

| Scenario | Response |
|----------|----------|
| Unclear requirements | Ask clarifying questions before planning |
| Large scope | Recommend breaking into multiple features |
| Missing dependencies | Identify blockers, suggest sequencing |
| Conflicting requirements | Surface trade-offs, request decision |
| Partial implementation blocked | Complete what is possible, mark blocked items with `[Blocked]`, report status |
| Test failures during implementation | Stop, report failing tests, do not proceed to next milestone |
| Existing feature overlap | Report the overlap, ask whether to extend existing or create new |

Never silently skip milestones or acceptance criteria—surface gaps and blockers explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/architecture` | Need high-level design before feature planning |
| `/patterns` | Feature requires specific design pattern |
| `/review` | Feature implementation needs code review |
| `/architecture --adr` | Feature involves significant technical decision |
| `/explore` | Need to understand existing features first |

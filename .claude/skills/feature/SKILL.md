---
name: feature
description: Use when the user asks to "implement a feature", "add new functionality", "build this feature", "feature development", mentions "user story", "feature spec", or needs structured feature planning and incremental implementation guidance.
argument-hint: "[feature name or description]"
allowed-tools: Read, Grep, Glob, Write
---

Guide structured feature development from specification through incremental implementation with clear milestones and verification steps.

## Development Philosophy

- **Incremental delivery** — ship working slices, not layers; each milestone produces demonstrable value
- **Specification before code** — clarify scope, acceptance criteria, and non-scope before writing implementation
- **User approval gates** — present plans for review before implementation; never proceed on assumptions
- **Test-driven confidence** — write tests first to encode expectations, then implement to satisfy them
- **Scope discipline** — build exactly what's needed; track out-of-scope items explicitly and defer them

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

| Input | Intent | Approach |
|-------|--------|----------|
| Feature name (e.g., `user authentication`) | Develop feature | Determine Feature Type, full Steps 1-5 |
| Feature + scope (e.g., `add OAuth to login`) | Scoped enhancement | Steps 1-5; emphasis on impact analysis (step 2) |
| User story (e.g., `as a user I want...`) | Story-driven development | Extract requirements from story, determine Feature Type, Steps 1-5 |
| File path / directory (e.g., `src/auth/`) | Module-scoped feature | Steps 1-5; analyze existing module first (step 2) |
| (none) | Ask user | Pre-flight stop |

## Feature Types

| Type | Indicators | Strategy |
|------|-----------|----------|
| **Greenfield** | "new feature", "add capability" | Full specification + implementation from scratch |
| **Enhancement** | "improve", "extend", "add to existing" | Impact analysis + incremental change to existing code |
| **Integration** | "connect", "integrate with" | Interface design + compatibility verification |
| **Migration** | "replace", "upgrade" | Parallel implementation + switchover plan |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent (Feature Name, Feature + Scope, User Story, File Path, or Ask User) using the Input Classification table
- Determine the Feature Type (Greenfield, Enhancement, Integration, or Migration) from the Feature Types section above
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

- **Define "Definition of Done"** — before planning milestones, define observable truths that must be TRUE when the feature is complete (see `@references/templates.md` for format)
  - Each truth must be verifiable: a file exists, a test passes, an endpoint responds, a query returns expected data
  - Organize by category: Artifacts, Behavior, Integration, Quality
- Break down into incremental milestones with: goal, tasks, dependencies, and verification criteria
- Each milestone should satisfy specific observable truths from the Definition of Done
- Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
- **Present the complete plan to the user before proceeding to implementation**
- Show: feature specification, Definition of Done, milestone breakdown, files to create/modify
- If changes requested, revise and present again

### 4. Implement

**Only proceed after user approval of the plan.**

For each milestone:
1. Write tests first encoding the acceptance criteria (TDD)
2. Implement minimum viable code to pass the tests
3. Verify against the milestone's verification criteria
4. Commit with clear message following project conventions

### 5. Verify

Perform three-level verification against the Definition of Done:

**Level 1 — Existence:** Confirm all planned artifacts exist (files, exports, tests, configs, migrations).

**Level 2 — Substance:** Verify implementations are real, not stubs. Scan for anti-patterns:
- TODO/FIXME comments in new code
- Stub returns (`return null`, `return {}`, `throw new Error('TODO')`)
- Empty catch blocks or console-only error handling
- Placeholder configuration values

**Level 3 — Wiring:** Verify all artifacts are connected:
- Exports are imported where needed
- Routes/handlers are registered
- Middleware is applied to correct paths
- Tests are included in test runner scope

**Final checks:**
- Confirm all observable truths from the Definition of Done are satisfied
- Verify all tests pass and cover key behaviors
- Check that implementation follows existing codebase patterns identified in Pre-flight
- Note any deferred items or out-of-scope work for follow-up
- If feature warrants it, recommend `/review` for formal code review or `/verify` for comprehensive completeness check

## Output Principles

- **Plan before code** — always present the feature specification and milestone breakdown for user review before writing any implementation
- **Milestone-driven progress** — each milestone produces a working, verifiable increment; never deliver untestable intermediate states
- **Explicit scope boundaries** — clearly state what is in-scope, out-of-scope, and deferred; surface any scope creep immediately
- **Test-first verification** — every acceptance criterion maps to a test; untested criteria are not verified

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
| `/plan` | Need to decompose a large goal before feature implementation |
| `/verify` | Need comprehensive post-implementation verification |
| `/debug` | Need to fix a bug, not implement a feature |

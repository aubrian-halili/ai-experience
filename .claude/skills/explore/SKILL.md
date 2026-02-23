---
name: explore
description: Use when the user asks "how does X work", "explain this feature", "trace this flow", "what does this module do", wants to understand existing code end-to-end, or needs deep codebase investigation.
argument-hint: "[feature, module, or flow to investigate]"
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

Systematically explore and explain how existing functionality works in the codebase.

## Exploration Principles

1. **Overview first, details second** — 1-3 sentence summary before diving into specifics
2. **Evidence-based** — Every claim references a file location (`file:line`)
3. **Dual context** — Never lose the original question while deep in implementation details
4. **Surface patterns** — Identify design patterns, architectural decisions, and implicit assumptions
5. **Explicit gaps** — Flag incomplete traces, dead ends, and areas not explored

## When to Use

### This Skill Is For

- Understanding how existing features and flows work end-to-end
- Tracing execution paths through the codebase
- Mapping component interactions and dependencies
- Investigating module structure and design patterns

### Use a Different Approach When

- Visualizing architecture → use `/diagram`
- Reviewing code quality → use `/review` or `/clean-code`
- Designing new architecture → use `/architecture`

## Exploration Strategies

**Single Function**: Read signature → trace body → resolve called functions → check callers for context
**API Endpoint**: Route definition → middleware chain → handler → service logic → DB/external calls → response
**Feature Flow**: UI trigger → API → service → data layer → async operations → event subscribers
**Module**: Public API (exports) → internal structure → core abstractions → external consumer patterns

## Process

### 1. Pre-flight

- Identify the investigation target from `$ARGUMENTS`
- Classify using the Exploration Strategies table above
- Determine depth: Surface (quick orientation) | Standard (full flow) | Deep (internals + edge cases)

**Stop conditions:**
- No `$ARGUMENTS` provided → ask user what to investigate
- Target not found in codebase → report and stop
- Target is ambiguous (multiple matches) → ask user to clarify
- Scope is overly broad (e.g., "how does everything work") → ask user to narrow focus

### 2. Discover

**Entry Points** — Locate route handlers, event listeners, CLI commands, or exported functions that trigger the flow
**Dependencies** — Trace imports outward; map internal modules and external services
**Data Flow** — Follow data from input to output through all transformations, validations, and serialization boundaries
**Control Flow** — Map execution path including branching, error handling, middleware, and async operations

### 3. Analyze

- Design patterns in use and why
- Architectural layer mapping (domain, application, infrastructure)
- Error handling and recovery strategy
- State management and side effects
- Configuration that alters behavior (env vars, feature flags)
- Performance considerations (bottlenecks, caching, async patterns)

### 4. Document

- Present findings with clear structure, file locations (`file:line`), and actionable observations
- List essential files to understand the feature
- Use tables for structured information (entry points, components, dependencies)
- Include diagrams (suggest `/diagram` for complex flows) where helpful
- Connect findings back to the user's original question

### 5. Verify

- Confirm the original question has been answered
- Check that all traced paths have been documented or marked `[Incomplete]`
- Note any areas intentionally not explored and why
- If findings suggest deeper analysis, recommend related skills (`/architecture`, `/diagram`, `/review`)

## Context Preservation

When investigating nested components, maintain dual context:

1. **Global Context**: Original investigation target and user's intent
   - What was the user trying to understand?
   - What question needs to be answered?

2. **Local Context**: Current component being analyzed
   - What does this specific piece do?
   - How does it relate to the global context?

Always maintain both contexts—don't lose sight of the broader goal when deep in implementation details. Periodically resurface to connect findings back to the original question.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what to investigate |
| Feature name (e.g., `authentication`) | Search for related files and trace the feature end-to-end |
| File path (e.g., `src/auth/login.ts`) | Start exploration from the specified file |
| Directory (e.g., `src/auth/`) | Explore the module structure and interactions |
| Flow description (e.g., `user login flow`) | Trace the flow from trigger to completion |
| Component name (e.g., `AuthService`) | Search for the component, trace its usage and dependencies |

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial results | Present findings with clear `[Incomplete]` markers |
| Uncertain findings | Mark sections as `[High Confidence]` or `[Needs Verification]` |
| Dead ends | Document paths that couldn't be traced and why |
| Scope limited | Explicitly state what was NOT explored (e.g., external services, dynamic dispatch) |
| Target not found | Report the missing target and ask user to verify the name or path |
| Scope too broad | Ask user to narrow scope to a specific feature, module, or flow |
| File access fails | Note inaccessible files and suggest alternative investigation approaches |

Never silently omit findings—surface limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/diagram` | Visual representation would clarify the flow |
| `/review` | Found issues that need formal review |
| `/architecture` | Understanding suggests architectural improvements |
| `/patterns` | Identified patterns need documentation or improvement |
| `/architecture --adr` | Discovery warrants documenting a decision |

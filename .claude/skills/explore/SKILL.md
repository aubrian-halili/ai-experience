---
name: explore
description: Use when the user asks "how does X work", "explain this feature", "trace this flow", "what does this module do", wants to understand existing code end-to-end, or needs deep codebase investigation.
argument-hint: "[feature, module, or flow to investigate]"
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

Systematically explore and explain how existing functionality works in the codebase.

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

## Process

### 1. Scope

- Identify the investigation target from `$ARGUMENTS`
- If broad, ask which aspect to focus on first
- Determine depth: Surface (quick orientation) | Standard (full flow) | Deep (internals + edge cases)

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

Present findings with clear structure, file locations (`file:line`), and actionable observations.

## Output Principles

- **Lead with overview** — 1-3 sentence summary before diving into details
- **Show locations** — Use `file:line` format for all references
- **Track data flow** — Visualize with diagrams where helpful
- **Surface patterns** — Identify design patterns and architectural decisions
- **Flag observations** — Tech debt, edge cases, implicit assumptions
- **Essential files** — List critical files to understand the feature
- **Use tables** — For structured information (entry points, components, dependencies)

## Exploration Strategies

**Single Function**: Read signature → trace body → resolve called functions → check callers for context
**API Endpoint**: Route definition → middleware chain → handler → service logic → DB/external calls → response
**Feature Flow**: UI trigger → API → service → data layer → async operations → event subscribers
**Module**: Public API (exports) → internal structure → core abstractions → external consumer patterns

## Context Preservation

When investigating nested components, maintain dual context:

1. **Global Context**: Original investigation target and user's intent
   - What was the user trying to understand?
   - What question needs to be answered?

2. **Local Context**: Current component being analyzed
   - What does this specific piece do?
   - How does it relate to the global context?

Always maintain both contexts—don't lose sight of the broader goal when deep in implementation details. Periodically resurface to connect findings back to the original question.

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial results | Present findings with clear `[Incomplete]` markers |
| Uncertain findings | Mark sections as `[High Confidence]` or `[Needs Verification]` |
| Dead ends | Document paths that couldn't be traced and why |
| Scope limited | Explicitly state what was NOT explored (e.g., external services, dynamic dispatch) |

Never silently omit findings—surface limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/diagram` | Visual representation would clarify the flow |
| `/review` | Found issues that need formal review |
| `/architecture` | Understanding suggests architectural improvements |
| `/patterns` | Identified patterns need documentation or improvement |
| `/architecture --adr` | Discovery warrants documenting a decision |

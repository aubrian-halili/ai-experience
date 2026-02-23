---
name: patterns
description: Use when the user asks "which pattern should I use", "how to implement [pattern name]", mentions "factory", "strategy", "observer", "singleton", "decorator", or discusses code structure problems that patterns could solve.
argument-hint: "[problem or pattern name]"
allowed-tools: Read, Grep, Glob
---

Provide guidance on selecting and implementing design patterns for specific problems.

## Pattern Philosophy

- **Simplest fit** — choose the simplest pattern that solves the problem; resist over-engineering
- **Composition over inheritance** — prefer patterns that compose behavior (Strategy, Decorator) over deep class hierarchies
- **Codebase alignment** — patterns must fit the project's language idioms, existing conventions, and team familiarity
- **Proven need** — patterns solve recurring, demonstrated problems, not hypothetical future ones

## When to Use

### This Skill Is For

- Recommending design patterns for specific problems
- Explaining and implementing specific patterns
- Comparing pattern alternatives with trade-offs
- Refactoring code smells using patterns
- Validating pattern usage

### Use a Different Approach When

- Reviewing code quality → use `/clean-code` or `/review`
- Making architectural decisions → use `/architecture`
- Understanding existing code → use `/explore`

## Input Classification

Classify the request to determine the appropriate approach:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Problem-First** | "how do I handle...", "what pattern for..." | Analyze problem → recommend pattern → show implementation |
| **Pattern-First** | "how to implement Factory", "show me Strategy" | Explain pattern → show implementation → discuss when to use |
| **Comparison** | "Factory vs Builder", "which is better" | Compare patterns → highlight trade-offs → recommend based on context |
| **Refactoring** | "replace these switch statements", "too many conditionals" | Identify smell → suggest pattern → show transformation |
| **Validation** | "is this the right pattern", "am I using this correctly" | Review usage → validate or suggest improvements |

## Process

### 1. Pre-flight

- Classify request using the Input Classification table
- Determine scope from `$ARGUMENTS`
- Search codebase for existing pattern usage
- Check for architecture docs or ADRs that constrain pattern choices

**Stop conditions:**

- No `$ARGUMENTS` provided → ask user what problem to solve or pattern to investigate
- Problem description too vague to classify → ask user to describe the specific behavior or structure problem
- Request is actually an architecture decision → redirect to `/architecture`

### 2. Analyze

- Problem domain: what varies, what is stable, what forces drive the design
- Existing code: current structure, language idioms, conventions
- Constraints: team size, language features, performance, existing abstractions
- Prior patterns already in use in the codebase

### 3. Recommend

- Select pattern(s) using Pattern Selection Guide
- Explain **why** the pattern fits: forces resolved, trade-offs accepted
- Show implementation sketch in project's language/style
- For comparisons: side-by-side with trade-off matrix
- For refactoring: before/after transformation

### 4. Verify

- Confirm recommendation addresses the original problem
- Discuss trade-offs and potential downsides
- Suggest complementary patterns
- Recommend `/architecture` or `/feature` or `/clean-code` for next steps as appropriate

## Pattern Selection Guide

| Problem | Consider |
|---------|----------|
| Complex object creation | Factory, Builder |
| Adding behavior dynamically | Decorator, Strategy |
| Incompatible interfaces | Adapter, Facade |
| State-dependent behavior | State, Strategy |
| Decoupling components | Observer, Mediator |
| External service calls | Circuit Breaker, Retry |
| Distributed transactions | Saga, Outbox |

## Output Principles

- **Why before what** — explain why a pattern fits the problem before showing implementation; forces and trade-offs matter more than syntax
- **Implementation in context** — show pattern code in the project's language and style, not textbook examples; reuse existing abstractions
- **Trade-off transparency** — explicitly state what the pattern costs (complexity, indirection, learning curve) alongside what it solves
- **Confidence signaling** — mark recommendations as `[High Confidence]` or `[Needs Verification]` so the user knows how certain the advice is

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what problem to solve or pattern to investigate |
| Problem description (e.g., `handling multiple payment methods`) | Problem-First workflow: analyze and recommend |
| Pattern name (e.g., `Strategy pattern`) | Pattern-First workflow: explain and show implementation |
| Comparison (e.g., `Factory vs Builder`) | Comparison workflow: side-by-side trade-off analysis |
| File path (e.g., `src/payments/processor.ts`) | Read the file, identify pattern opportunities or validate existing patterns |

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial analysis | Present findings with clear `[Incomplete]` markers |
| Uncertain recommendation | Mark as `[High Confidence]` or `[Needs Verification]` |
| Missing context | State assumptions explicitly and ask user to confirm |
| Multiple valid options | Present alternatives with trade-offs, let user decide |
| Target file not found | Report the missing file and ask user to verify the path |
| Scope too broad | Ask user to narrow to a specific problem, module, or pattern family |
| Pattern not applicable | Explain why the pattern does not fit and suggest alternatives |
| Codebase access limited | Note inaccessible files and suggest alternative investigation approaches |

Never silently commit to a pattern—surface uncertainty and let the user decide.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/clean-code` | Pattern implementation needs quality review |
| `/architecture` | Pattern choice has broader architectural implications |
| `/architecture --adr` | Pattern decision should be documented |
| `/diagram` | Pattern structure needs visualization |
| `/review` | Existing pattern usage needs evaluation |

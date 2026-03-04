---
name: brainstorming
description: Use when the user asks to "brainstorm", "explore options", "compare approaches", "what are my options", "how should I approach", "trade-offs", "pros and cons", mentions "design alternatives", or "solution space".
argument-hint: "[problem, goal, or design question]"
allowed-tools: Read, Grep, Glob, Skill
---

Explore the solution space for a problem by comparing approaches, surfacing trade-offs, and converging on a recommended direction before committing to implementation.

## Brainstorming Philosophy

- **Diverge before converge** — explore broadly first, narrow later; premature convergence kills innovation
- **Trade-offs, not opinions** — every option has costs and benefits; present both honestly
- **Challenge assumptions** — question constraints that appear fixed; ask "must this be true?"
- **One question at a time** — clarifying questions asked sequentially, never in batches
- **No implementation until convergence** — this skill produces a direction, not code

## Iron Laws

> - NO implementation actions (Write, Edit, Bash) during brainstorming
> - NO convergence without presenting at least 2 viable options
> - If the user jumps to implementation, redirect to `/plan` or `/feature`

## When to Use

### This Skill Is For

- Exploring multiple solutions before picking one
- Comparing architectural approaches for a new feature
- Evaluating technology or library choices
- Challenging assumptions about a design direction
- Pre-plan ideation when the path forward is unclear

### Use a Different Approach When

- Solution is already chosen, need implementation plan → use `/plan`
- Need to understand existing code → use `/explore`
- Need architecture documentation → use `/architecture`
- Ready to build → use `/feature`

## Input Classification

| Input | Intent | Approach |
|-------|--------|----------|
| Problem statement (e.g., `how should we handle auth?`) | Explore solution space | Full Steps 1-5 |
| Technology comparison (e.g., `Redis vs DynamoDB for caching`) | Compare specific options | Skip to Step 2 with pre-defined options |
| Vague direction (e.g., `make the API faster`) | Discover the real problem | Step 1 emphasis on clarification |
| (none) | Ask user | Pre-flight stop |

## Process

### 1. Frame the Problem

- Parse `$ARGUMENTS` and identify the core design question
- Search the codebase for relevant context: existing patterns, constraints, dependencies
- Ask clarifying questions ONE AT A TIME until the problem is well-defined
- Identify explicit constraints (must-haves) vs. implicit assumptions (might-haves)

**Stop conditions:**
- No `$ARGUMENTS` provided → ask user what to brainstorm
- Problem is already well-defined with a clear solution → suggest `/plan` instead
- Problem is a bug, not a design question → suggest `/debug` instead

### 2. Generate Options

- Produce 2-3 distinct approaches (not variations of the same idea)
- For each option, identify:
  - **Core idea**: one-sentence description
  - **How it works**: brief technical sketch
  - **Strengths**: what this approach does well
  - **Weaknesses**: what this approach does poorly or makes harder
  - **Assumptions**: what must be true for this to work
  - **Codebase fit**: how well it aligns with existing patterns (reference specific files/patterns)

- If the codebase already has a strong pattern, note it but still explore alternatives — the goal is informed choice, not inertia

### 3. Surface Trade-offs

Present a comparison matrix:

| Dimension | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| Complexity | | | |
| Performance | | | |
| Maintainability | | | |
| Migration effort | | | |
| Risk | | | |

Add dimensions relevant to the specific problem. Remove irrelevant ones.

### 4. Recommend

- State a recommended direction with clear rationale
- Explain what you'd give up by choosing this option
- Note any assumptions that should be validated before committing
- If no clear winner exists, say so — present the deciding factors and let the user choose

### 5. Converge

- After user selects a direction, summarize the decision and rationale
- Recommend next step: `/plan` to formalize into implementation phases
- Do NOT begin implementation — brainstorming ends at convergence

## Output Principles

- **Structured comparison** — always use a comparison table; narrative comparisons are harder to evaluate
- **Honest trade-offs** — never present a "clear winner" unless the trade-offs genuinely favor one option
- **Codebase grounding** — reference actual files and patterns, not theoretical best practices
- **Decision, not code** — output is a direction with rationale, never implementation

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what problem to brainstorm |
| Problem statement | Full brainstorming workflow |
| Technology comparison | Skip framing, go directly to option generation |
| Vague direction | Emphasize problem framing with clarifying questions |

## Error Handling

| Scenario | Response |
|----------|----------|
| Problem too vague | Ask clarifying questions one at a time |
| Only one viable option | Present it honestly, explain why alternatives don't work |
| User wants to skip to implementation | Redirect to `/plan` or `/feature` with the chosen direction |
| Conflicting constraints | Surface the conflict explicitly, ask user to prioritize |
| Codebase context insufficient | Note gaps, recommend `/explore` before continuing |

Never present false equivalence — if one option is clearly better, say so with evidence.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Direction is chosen, need implementation phases |
| `/architecture` | Need formal architecture documentation or ADR |
| `/feature` | Ready to implement, not explore |
| `/explore` | Need to understand existing code before brainstorming |

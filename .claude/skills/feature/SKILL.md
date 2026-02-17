---
name: feature
description: Use when the user asks to "implement a feature", "add new functionality", "build this feature", "feature development", mentions "user story", "feature spec", or needs structured feature planning and incremental implementation guidance.
argument-hint: "[feature name or description]"
---

Guide structured feature development from specification through incremental implementation with clear milestones and verification steps.

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

Use `$ARGUMENTS` if provided (feature name or description).

### 1. Feature Specification

Gather requirements: problem statement, user stories, acceptance criteria, out-of-scope items, and dependencies.

### 2. Technical Analysis

Analyze the codebase for existing patterns to follow, code to modify vs. create, integration points, and test coverage requirements.

### 3. Implementation Plan

Break down into incremental milestones with deliverables, dependencies, and verification steps. See `@references/templates.md` for the full Feature Development Plan template.

### 4. Incremental Implementation

For each milestone: write tests first (TDD), implement minimum viable code, verify against acceptance criteria, commit with clear message.

### 5. Feature Verification

Ensure all acceptance criteria met, tests passing, code reviewed, and documentation updated.

## Error Handling

| Scenario | Response |
|----------|----------|
| Unclear requirements | Ask clarifying questions before planning |
| Large scope | Recommend breaking into multiple features |
| Missing dependencies | Identify blockers, suggest sequencing |
| Conflicting requirements | Surface trade-offs, request decision |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/architecture` | Need high-level design before feature planning |
| `/patterns` | Feature requires specific design pattern |
| `/review` | Feature implementation needs code review |
| `/architecture --adr` | Feature involves significant technical decision |
| `/explore` | Need to understand existing features first |

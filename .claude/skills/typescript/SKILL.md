---
name: typescript
description: Use when the user asks about "TypeScript", "TS types", "type error", "generics", "type inference", mentions "tsconfig", "strict mode", "type narrowing", or needs TypeScript-specific guidance, type definitions, and advanced typing patterns.
argument-hint: "[code, type, or TypeScript question]"
allowed-tools: Read, Grep, Glob
---

Provide TypeScript-specific guidance including type definitions, generics, type inference, compiler configuration, and advanced typing patterns.

## When to Use

### This Skill Is For

- Writing type definitions and interfaces
- Fixing TypeScript compiler errors
- Designing generic types and utilities
- Configuring tsconfig.json
- Type narrowing and guards
- Advanced typing patterns
- Migration from JavaScript to TypeScript

### Use a Different Approach When

- General code review → use `/review`
- Architecture decisions → use `/architecture`
- Testing TypeScript code → use `/testing`

## Process

Use `$ARGUMENTS` if provided (code snippet, type, or TypeScript question).

### 1. Understand the Context

Identify TypeScript version, tsconfig strictness level, and framework/library context.

### 2. Analyze the Problem

Determine if it's a type definition issue, compiler configuration issue, or type inference issue.

### 3. Provide Solution

Offer type definitions with explanations, configuration recommendations, and code examples showing correct usage.

See `@references/patterns.md` for comprehensive TypeScript patterns including:
- Common Type Patterns (Basic Types, Utility Types)
- Generic Patterns
- Type Narrowing
- Advanced Patterns (Mapped, Conditional, Template Literal, Recursive, Branded)
- Error Handling Patterns
- tsconfig.json Best Practices
- Common Error Solutions
- Declaration File Patterns

## Error Handling

| Scenario | Response |
|----------|----------|
| Complex type error | Break down the error, explain each part |
| Generic confusion | Start with concrete types, then generalize |
| tsconfig questions | Explain impact of each option |
| Type inference issues | Show explicit types to clarify |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Code review including TypeScript quality |
| `/clean-code` | Refactoring TypeScript code |
| `/testing` | Writing tests for TypeScript code |
| `/patterns` | Design patterns in TypeScript |

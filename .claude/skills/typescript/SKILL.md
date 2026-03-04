---
name: typescript
description: Use when the user asks about "TypeScript", "TS types", "type error", "generics", "type inference", mentions "tsconfig", "strict mode", or "type narrowing".
argument-hint: "[code, type, or TypeScript question]"
allowed-tools: Read, Grep, Glob
---

Provide TypeScript-specific guidance including type definitions, generics, type inference, compiler configuration, and advanced typing patterns.

## TypeScript Philosophy

- **Strict by default** — enable `strict: true` and opt out of individual checks only with documented justification; loosening strictness is a design decision, not a convenience shortcut
- **Let inference work** — annotate function signatures and exports; let the compiler infer locals, return types of simple expressions, and generic type arguments where unambiguous
- **Model the domain** — types should encode business constraints (branded types, discriminated unions, exhaustive checks); if a bug is representable in your type system, someone will write it
- **Narrow over assert** — prefer type guards and control flow narrowing over type assertions (`as`) and non-null assertions (`!`); assertions silence the compiler without proving correctness
- **Incremental adoption** — when migrating from JavaScript, prioritize strict null checks and explicit `any` elimination over perfect types; good types today beat perfect types never

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

## Input Classification

Classify `$ARGUMENTS` to determine the TypeScript guidance scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Determine TypeScript question | Ask user for specific question, error, or file path |
| Code snippet (e.g., `function foo<T>(x: T)`) | Analyze types in snippet | Type analysis with tsconfig context check |
| Error message (e.g., `Type 'string' is not assignable to type 'number'`) | Diagnose type error | Error decomposition and type conflict tracing |
| File path (e.g., `src/models/user.ts`) | Analyze file types | Read file, evaluate type definitions and usage |
| tsconfig question (e.g., `strictNullChecks`) | Explain configuration | Option impact analysis with recommendation |
| Pattern request (e.g., `branded types`, `discriminated union`) | Explain type pattern | Pattern lookup from `@references/patterns.md` |

## Process

### 1. Pre-flight

- Classify TypeScript scope from `$ARGUMENTS` using the Input Classification table
- If `$ARGUMENTS` contains a file path, read the file via Read
- If `$ARGUMENTS` contains an error message, extract the error code (e.g., `TS2345`) and isolate the conflicting types
- If `$ARGUMENTS` contains a code snippet, identify the TypeScript version and strictness context
- Search codebase for `tsconfig.json` to determine project strictness level and module system

**Stop conditions:**
- No `$ARGUMENTS` and no code context provided → ask user for a specific TypeScript question, error, or file
- Target file not found → report and ask user to verify the path
- Request is not TypeScript-specific (general code quality, architecture) → redirect to appropriate skill

### 2. Analyze Context

- Identify the TypeScript version constraints (target, lib, module system)
- Determine strictness level (`strict: true`, individual flags, or loose)
- Note the framework context (React, Node, Express, etc.) that affects type patterns
- For type errors: identify the expected type, actual type, and the assignment or call site
- For type design: identify what varies, what is constrained, and what the consumer API should look like

### 3. Diagnose

**For type errors and inference issues:**
- Break the error into constituent parts (expected vs actual, constraint chain)
- Trace the type through inference steps to find where it diverges
- Identify whether the root cause is a missing annotation, incorrect constraint, or structural mismatch

**For type design and narrowing:**
- Select applicable patterns from `@references/patterns.md` (Generic Patterns, Advanced Patterns, Type Narrowing)
- Evaluate trade-offs: readability vs type safety, inference vs explicit annotation, nominal vs structural
- Consider whether existing utility types (`Partial`, `Pick`, `Omit`, `Record`) solve the problem before designing custom types

**For configuration:**
- Map the question to specific tsconfig options from `@references/patterns.md` (tsconfig.json Best Practices)
- Explain the impact of each relevant option on type checking behavior

### 4. Recommend Solution

- Provide the recommended type definition, configuration change, or error fix
- Include a code example showing correct usage with inline comments explaining type behavior
- For type errors: show the fix and explain why the original code failed
- For type design: show the pattern with a concrete usage example, not just the type definition in isolation
- For migration: provide an incremental adoption path (`.js` → `.ts` with `allowJs`, then strict null checks, then full strict)
- Cross-reference specific sections from `@references/patterns.md` where applicable

### 5. Verify Correctness

- Confirm the recommendation satisfies the original constraint (type error resolved, design requirement met)
- Check that the recommendation aligns with the project's strictness level
- Note if the recommendation depends on specific TypeScript version features
- If the solution involves trade-offs (e.g., type assertion, `any` escape hatch), state them explicitly
- Suggest related improvements if found during analysis (e.g., "enabling `noUncheckedIndexedAccess` would catch similar issues")

## Output Principles

- **Show the types** — always include the relevant type signatures in code blocks; TypeScript guidance without visible types is incomplete
- **Explain inference** — when the compiler infers a type, show what it infers and why; users need to understand the inference chain, not just the final result
- **Concrete before abstract** — demonstrate patterns with concrete domain types first, then generalize; a `UserRepository<User>` example teaches better than `Repository<T>`
- **Strictness-aware** — frame recommendations for the project's actual strictness level; do not recommend patterns that require `strictNullChecks` if the project has it disabled without noting the dependency

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user for a specific TypeScript question, error message, or file path |
| Code snippet (e.g., `function foo<T>(x: T)`) | Analyze the snippet in isolation; ask for tsconfig context if strictness matters |
| Error message (e.g., `Type 'string' is not assignable to type 'number'`) | Decompose the error, trace the type conflict, recommend fix |
| File path (e.g., `src/models/user.ts`) | Read the file, analyze type definitions and usage patterns |
| tsconfig question (e.g., `strictNullChecks`) | Explain the option, its impact, and recommended setting |
| Pattern request (e.g., `branded types`, `discriminated union`) | Look up in `@references/patterns.md`, explain with project-contextual example |

## Error Handling

| Scenario | Response |
|----------|----------|
| No argument or context provided | Ask user for a specific TypeScript question, error, or file |
| Target file not found | Report the missing path and ask user to verify |
| Complex type error (nested generics, conditional types) | Break the error into layers; explain each inference step separately |
| Conflicting type guidance | State both options with trade-offs; let user decide based on project constraints |
| TypeScript version mismatch | Note which version introduced the feature; suggest alternatives for older versions |
| tsconfig option interaction | Explain how options interact (e.g., `strict` enables `strictNullChecks`); recommend testing changes incrementally |
| Cannot determine project strictness | State assumption (`strict: true` default), ask user to confirm |
| Migration scope too broad | Recommend incremental migration starting with the highest-value files (shared types, API boundaries) |

Never silently assume strictness level or TypeScript version—surface assumptions explicitly and let the user confirm.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Code review including TypeScript quality |
| `/clean-code` | Refactoring TypeScript code for maintainability |
| `/patterns` | Design patterns implemented in TypeScript |
| `/explore` | Understand existing TypeScript codebase before asking type questions |
| `/testing` | Writing tests for TypeScript code |

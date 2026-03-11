---
name: react
description: >-
  TRIGGER when: user asks about React components, hooks, JSX/TSX, Redux Toolkit, RTK Query, React state
  management, React Testing Library, mentions "custom hook", "useEffect", "useState", or asks how to build
  a UI component in React.
  DO NOT TRIGGER when: user asks about general UI design principles without React (use /frontend-design),
  general TypeScript without React context (use /typescript), or wants a quick HTML prototype
  (use /playground).
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, WebSearch, WebFetch
argument-hint: "[component name, pattern question, or leave blank for guidance]"
---

## React Philosophy

- **Composition over inheritance** — Build complex UIs by combining small, focused components. Never use class inheritance for component reuse.
- **Colocate what changes together** — Keep styles, tests, types, and logic near the component that owns them. Feature folders over type folders.
- **Minimal state, derive the rest** — Store only the source of truth in state. Compute everything else in render or with selectors.
- **Server state is not client state** — Use RTK Query for server-cached data. Use Redux slices only for truly client-owned state (UI preferences, form drafts, auth tokens).
- **Render predictability** — Components are pure functions of props and state. Side effects belong in hooks, thunks, or RTK Query lifecycle callbacks — never in render.

## When to Use

### This Skill Is For

- Creating new React components (functional only)
- Designing custom hooks
- Setting up Redux Toolkit slices and store
- Configuring RTK Query APIs with cache invalidation
- Writing tests with React Testing Library and Jest
- Debugging React rendering, state, or performance issues
- Refactoring class components to functional components
- Optimizing re-renders with memoization

### Use a Different Approach When

- Pure TypeScript types/utilities → use `/typescript`
- Backend API implementation → use `/aws`
- General testing strategy → use `/testing`
- Architecture decisions (ADRs) → use `/architecture`
- Security concerns (XSS, auth) → use `/security`

## Input Classification

Classify `$ARGUMENTS` to determine the React development scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Determine React task | Ask user for component, hook, file path, or question |
| Name or description (e.g., `UserProfile`, `useAuth hook`) | Scaffold or design | Create component/hook with types and test file |
| File path (e.g., `src/components/Header.tsx`) | Analyze existing code | Read file, evaluate patterns, types, and test coverage |
| Action + target (e.g., `test LoginForm`, `create cart slice`) | Execute targeted operation | Apply workflow for testing, scaffolding, or optimization |
| Bug/error description (e.g., `infinite re-renders`, `state not updating`) | Diagnose and fix | Root cause analysis with targeted fix |
| Concept/pattern question (e.g., `RTK Query caching`, `compound components`) | Explain pattern | Pattern lookup from `@references/patterns.md` with examples |

## Process

### 1. Pre-flight

- Classify React scope from `$ARGUMENTS` using the Input Classification table
- Detect project setup: check for `package.json` dependencies (`react`, `@reduxjs/toolkit`, `react-router`, etc.)
- Find existing patterns: scan for component conventions, file structure, naming
- Identify testing setup: look for Jest config, RTL utilities, MSW handlers
- Check for existing store configuration and API definitions

**Stop conditions:**
- No `$ARGUMENTS` and no React file context provided → ask user to specify component, hook, or file
- Target file or component not found → report and ask user to verify the path
- No React detected in `package.json` → warn, offer to proceed or scaffold setup
- Request is not React-specific (general TypeScript, backend) → redirect to appropriate skill

### 2. Context Analysis

- Map the component tree around the target area
- Identify state boundaries: what's local, what's in Redux, what's server state
- Check for existing types and interfaces
- Review related tests for coverage gaps

### 3. Implementation

Apply patterns from @references/patterns.md based on the classification:

- **Components**: Start with the simplest pattern that works. Add complexity only when needed.
- **Hooks**: Define the API (inputs/outputs) first, then implement.
- **Redux**: One slice per feature domain. Typed hooks everywhere.
- **RTK Query**: Define tags upfront. Cache invalidation strategy before endpoints.

Key rules:
- Always use TypeScript with explicit prop interfaces
- Export named components (no default exports)
- Colocate: `Component.tsx`, `Component.test.tsx`, `Component.types.ts` in same directory
- Hooks return objects (not arrays) for named destructuring — except simple two-value hooks

### 4. Testing Guidance

Apply testing patterns from @references/testing.md:

- Every component gets a test file
- Follow RTL query priority: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`
- Test behavior, not implementation — no snapshots, no internal state checks
- Redux-connected components get a `renderWithStore` wrapper
- RTK Query tests use MSW for network mocking

### 5. Verification

- Confirm all new files follow the colocation convention
- Check that TypeScript compiles (`tsc --noEmit` if available)
- Verify tests pass
- Review for common anti-patterns (see @references/patterns.md anti-patterns table)

## Output Principles

- **TypeScript first** — All code includes types. No `any` unless explicitly justified.
- **Testable by design** — Every component and hook is designed for easy testing.
- **Minimal API surface** — Props interfaces expose only what consumers need.
- **Pragmatic conventions** — Follow naming conventions (`useXxx`, `XxxSlice`, `xxxApi`); extract shared patterns only after three instances.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Show available workflows and ask for context |
| Name or description (e.g., `UserProfile`, `useAuth hook`) | Scaffold component/hook with types and test file |
| File path (e.g., `src/components/Header.tsx`) | Read file, analyze patterns and issues |
| Action + target (e.g., `test LoginForm`, `create cart slice`) | Execute targeted workflow (test, scaffold, optimize) |
| Bug/error description (e.g., `LoginForm re-renders on every keystroke`) | Diagnose root cause, recommend fix |
| Concept/pattern question (e.g., `RTK Query cache invalidation`) | Explain pattern with examples from references |

## Error Handling

| Scenario | Response |
|----------|----------|
| No React in `package.json` | Warn that React is not detected; offer to proceed or scaffold setup |
| Class component encountered | Offer refactoring path to functional component |
| No test utilities found | Suggest RTL + Jest setup before writing tests |
| Conflicting state patterns (context + Redux for same data) | Flag the conflict and recommend consolidation |
| Missing TypeScript config | Warn and offer to proceed with JS or set up TS |

Never silently assume component architecture or state management approach—surface assumptions explicitly and let the user confirm.

## Related Skills

| Skill | When to Use Instead |
|-------|-------------------|
| `/typescript` | Pure type design, utility types, generics |
| `/testing` | General testing strategy beyond React |
| `/patterns` | Design patterns not specific to React |
| `/clean-code` | General code quality and refactoring principles |
| `/security` | XSS prevention, auth flows, input sanitization |
| `/explore` | Understand existing component structure first |
| `/frontend-design` | Visual design, accessibility, and responsive layout |

---
name: react
description: React development guidance including component design, hooks, Redux Toolkit, RTK Query, state management, and testing with React Testing Library. Use when working with React components, Redux slices, RTK Query APIs, custom hooks, JSX/TSX files, or frontend state management.
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, WebSearch, WebFetch
user-invocable: true
argument-hint: "[component name, pattern question, or leave blank for guidance]"
---

## React Philosophy

1. **Composition over inheritance** — Build complex UIs by combining small, focused components. Never use class inheritance for component reuse.
2. **Colocate what changes together** — Keep styles, tests, types, and logic near the component that owns them. Feature folders over type folders.
3. **Minimal state, derive the rest** — Store only the source of truth in state. Compute everything else in render or with selectors.
4. **Server state is not client state** — Use RTK Query for server-cached data. Use Redux slices only for truly client-owned state (UI preferences, form drafts, auth tokens).
5. **Render predictability** — Components are pure functions of props and state. Side effects belong in hooks, thunks, or RTK Query lifecycle callbacks — never in render.

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

| Scenario | Use Instead |
|----------|-------------|
| Pure TypeScript types/utilities | `/typescript` |
| Backend API implementation | `/aws` |
| General testing strategy | `/testing` |
| Architecture decisions (ADRs) | `/architecture` |
| Security concerns (XSS, auth) | `/security` |

## Input Classification

| Input Pattern | Classification | Workflow |
|---------------|---------------|----------|
| Component name or description | **New Component** | Scaffold component + types + test file |
| "hook" or custom hook name | **Custom Hook** | Design hook API, implement, test with `renderHook` |
| "slice", "store", "state", Redux keyword | **State Management** | Design slice/selectors or configure store |
| "query", "mutation", "API", "cache", RTK Query keyword | **RTK Query** | Define API endpoints with tags and cache config |
| "test" or "testing" with component context | **Testing** | Write RTL tests following query priority |
| "slow", "re-render", "memo", "performance" | **Performance** | Diagnose and optimize with profiling guidance |
| "bug", "broken", "not working", error description | **Bug Fix** | Pre-flight analysis, root cause, targeted fix |
| "refactor" or structural change request | **Refactor** | Analyze current structure, propose incremental changes |
| File path (`.tsx`, `.jsx`, `.ts` in component dir) | **File Analysis** | Read file, identify issues or improvement opportunities |
| No argument | **Guidance** | Show available workflows and ask for context |

## Process

### 1. Pre-flight

- Detect project setup: check for `package.json` dependencies (`react`, `@reduxjs/toolkit`, `react-router`, etc.)
- Find existing patterns: scan for component conventions, file structure, naming
- Identify testing setup: look for Jest config, RTL utilities, MSW handlers
- Check for existing store configuration and API definitions

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
- **Consistent naming** — `useXxx` for hooks, `XxxSlice` for slices, `xxxApi` for RTK Query.
- **No premature abstraction** — Three instances before extracting a pattern.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| `UserProfile` | Create a `UserProfile` component with types and test |
| `useAuth hook` | Design and implement a `useAuth` custom hook |
| `create a slice for cart` | Scaffold a Redux Toolkit slice for cart feature |
| `RTK Query for /users` | Define an RTK Query API for the users endpoint |
| `test LoginForm` | Write RTL tests for the `LoginForm` component |
| `optimize ProductList` | Profile and optimize `ProductList` re-renders |
| `src/components/Header.tsx` | Read and analyze the Header component |
| _(empty)_ | Show available workflows and ask what to build |

## Error Handling

| Scenario | Response |
|----------|----------|
| No React in `package.json` | Warn that React is not detected; offer to proceed or scaffold setup |
| Class component encountered | Offer refactoring path to functional component |
| No test utilities found | Suggest RTL + Jest setup before writing tests |
| Conflicting state patterns (context + Redux for same data) | Flag the conflict and recommend consolidation |
| Missing TypeScript config | Warn and offer to proceed with JS or set up TS |

## Related Skills

| Skill | When to Use Instead |
|-------|-------------------|
| `/typescript` | Pure type design, utility types, generics |
| `/testing` | General testing strategy beyond React |
| `/patterns` | Design patterns not specific to React |
| `/clean-code` | General code quality and refactoring principles |
| `/security` | XSS prevention, auth flows, input sanitization |
| `/aws` | Backend APIs that React consumes via RTK Query |

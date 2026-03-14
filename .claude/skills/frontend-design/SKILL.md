---
name: frontend-design
description: >-
  User asks about "UI design", "design system", "accessibility", "WCAG",
  "visual hierarchy", or "typography". Framework-agnostic design principles.
  Not for: building React components (use /react), throwaway prototypes
  (use /playground).
argument-hint: "[component, page, or design concern]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

Guide creation of distinctive, production-grade interfaces with strong visual hierarchy, accessibility, and responsive design.

## Design Philosophy

- **Visual hierarchy first** — every screen has one primary action and a clear reading order; if everything is bold, nothing is
- **Accessibility is not optional** — WCAG 2.1 AA compliance is the baseline, not a nice-to-have; contrast ratios, keyboard navigation, and screen reader support from the start
- **Systematic spacing** — use a consistent spacing scale; ad-hoc pixel values create visual noise that users feel but can't name
- **Responsive by default** — design for the smallest screen first, then enhance; breakpoints should feel natural, not forced
- **Restraint over decoration** — fewer visual elements with more purpose; whitespace is a design tool, not wasted space

## Input Handling

Classify `$ARGUMENTS` to determine the design scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | General design guidance | Ask for specific component or page |
| Component name (e.g., `Button`, `Modal`) | Design component | Apply design principles to component |
| Page/feature (e.g., `dashboard`, `settings page`) | Design page layout | Visual hierarchy + responsive layout |
| Design concern (e.g., `spacing`, `colors`) | System guidance | Provide scale and usage guidelines |
| File path (e.g., `src/components/Card.tsx`) | Audit existing design | Review and suggest improvements |
| `accessibility` or `a11y` | Accessibility audit | WCAG 2.1 AA compliance check |

## Process

### 1. Pre-flight

- Classify design scope from `$ARGUMENTS` using the Input Handling table
- Check for existing design tokens, theme files, or CSS variables in the project
- Identify the CSS approach: CSS modules, styled-components, Tailwind, vanilla CSS
- Look for existing component library usage (MUI, Radix, shadcn, etc.)

**Stop conditions:**
- No `$ARGUMENTS` and no design context → ask user for component, page, or concern
- Request is purely about logic/state → redirect to `/react`
- Request is about backend → redirect to appropriate skill

### 2. Analyze Current State

For existing components/pages:

1. Read the current implementation
2. Evaluate against design principles from `@references/design-principles.md`
3. Check accessibility: contrast ratios, semantic HTML, ARIA labels, keyboard support
4. Assess responsive behavior: does it work at 320px, 768px, 1024px, 1440px?

### 3. Design Recommendations

Provide specific, actionable guidance:

1. **Visual hierarchy**: Primary/secondary/tertiary element identification
2. **Spacing**: Apply consistent scale (4px base: 4, 8, 12, 16, 24, 32, 48, 64)
3. **Typography**: Size scale, weight usage, line height
4. **Color**: Contrast ratios, semantic color usage, dark/light mode support
5. **Layout**: Grid/flexbox strategy, container widths, responsive breakpoints
6. **Interaction**: Hover/focus/active states, transitions, feedback

### 4. Implementation

When writing or modifying CSS/components:

- Use CSS custom properties for design tokens
- Ensure all interactive elements have visible focus indicators
- Add appropriate ARIA attributes
- Test responsive behavior at key breakpoints
- Include reduced-motion media query for animations

### 5. Verify

- Check all color combinations meet WCAG AA contrast ratio (4.5:1 for text, 3:1 for large text)
- Verify keyboard navigation works for all interactive elements
- Confirm responsive layout doesn't break at any viewport width
- Review for consistent spacing scale usage

## Output Principles

- **Show, don't just tell** — include code examples with before/after for every suggestion
- **Measurable standards** — cite specific WCAG criteria, contrast ratios, and spacing values
- **Progressive enhancement** — suggestions should improve without breaking existing functionality
- **Framework-aware** — adapt recommendations to the project's CSS approach

## Error Handling

| Scenario | Response |
|----------|----------|
| No existing design system | Propose a minimal token set (colors, spacing, typography) |
| Mixed CSS approaches in project | Note the inconsistency, recommend consolidation path |
| Component library in use | Adapt suggestions to work within the library's constraints |
| Accessibility violation found | Flag with WCAG criterion reference and specific fix |
| No responsive styles present | Provide mobile-first responsive strategy |
| Design conflicts with existing patterns | Highlight the conflict, suggest resolution |

Never sacrifice accessibility for aesthetics — if a design choice creates an accessibility issue, always choose the accessible option.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/react` | Component logic, state management, hooks |
| `/playground` | Quick interactive prototypes |
| `/review` | Code quality beyond visual design |
| `/review` | General code review including but not focused on design |

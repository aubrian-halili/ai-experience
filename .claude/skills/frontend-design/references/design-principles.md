# Design Principles Reference

## Visual Hierarchy Checklist

- [ ] One clear primary action per screen/section
- [ ] Size establishes importance (larger = more important)
- [ ] Color draws attention to key elements; muted tones for secondary content
- [ ] Whitespace groups related elements and separates sections
- [ ] Reading order follows natural eye movement (F-pattern for text-heavy, Z-pattern for landing pages)
- [ ] No more than 3 levels of visual emphasis on any screen

## Spacing Scale (4px base)

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Inline element gaps, icon padding |
| `--space-2` | 8px | Tight grouping, small component padding |
| `--space-3` | 12px | Default input padding, list item gaps |
| `--space-4` | 16px | Card padding, section gaps |
| `--space-6` | 24px | Content section spacing |
| `--space-8` | 32px | Major section breaks |
| `--space-12` | 48px | Page section spacing |
| `--space-16` | 64px | Hero/header spacing |

**Rule:** Use only values from the scale. If a value feels wrong, move to the next step up or down — don't invent custom values.

## Typography Scale

| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Display | 2.25rem (36px) | 700 | 1.2 | Hero headings |
| H1 | 1.875rem (30px) | 700 | 1.3 | Page titles |
| H2 | 1.5rem (24px) | 600 | 1.3 | Section headings |
| H3 | 1.25rem (20px) | 600 | 1.4 | Subsection headings |
| Body | 1rem (16px) | 400 | 1.5 | Default text |
| Small | 0.875rem (14px) | 400 | 1.5 | Captions, labels |
| Tiny | 0.75rem (12px) | 500 | 1.4 | Badges, footnotes |

**Rules:**
- Max 2 font families (one sans-serif, one monospace)
- Max 3 font weights per family
- Line length: 45-75 characters for body text

## Color & Contrast

### WCAG 2.1 AA Requirements

| Element | Minimum Contrast Ratio |
|---------|----------------------|
| Normal text (<18px) | 4.5:1 |
| Large text (>=18px bold or >=24px) | 3:1 |
| UI components and graphical objects | 3:1 |
| Focus indicators | 3:1 against adjacent colors |

### Semantic Color Usage

| Purpose | Token | Usage |
|---------|-------|-------|
| Primary | `--color-primary` | CTAs, active states, links |
| Success | `--color-success` | Confirmations, positive states |
| Warning | `--color-warning` | Caution states, pending |
| Danger | `--color-danger` | Errors, destructive actions |
| Neutral | `--color-neutral` | Text, borders, backgrounds |

**Rules:**
- Never use color as the only indicator (add icons, text, or patterns)
- Test with color blindness simulators
- Provide dark mode alternative colors

## Responsive Breakpoints

| Name | Width | Target |
|------|-------|--------|
| Mobile | 320-767px | Phones |
| Tablet | 768-1023px | Tablets, small laptops |
| Desktop | 1024-1439px | Laptops, monitors |
| Wide | 1440px+ | Large monitors |

### Common Responsive Patterns

- **Stack to grid**: Single column on mobile, multi-column on desktop
- **Collapse navigation**: Hamburger on mobile, horizontal nav on desktop
- **Hide secondary content**: Show on desktop, collapse/accordion on mobile
- **Fluid typography**: `clamp()` for sizes that scale with viewport
- **Container queries**: Size components based on container, not viewport

```css
/* Fluid typography example */
h1 { font-size: clamp(1.5rem, 4vw, 2.25rem); }

/* Container query example */
@container (min-width: 400px) {
  .card { flex-direction: row; }
}
```

## Animation Guidelines

### Timing

| Type | Duration | Easing | Usage |
|------|----------|--------|-------|
| Micro | 100-150ms | ease-out | Button press, toggle |
| Small | 200-300ms | ease-in-out | Expand/collapse, fade |
| Medium | 300-500ms | ease-in-out | Page transitions, modals |
| Large | 500ms+ | custom | Complex orchestrated animations |

### Rules

- Always respect `prefers-reduced-motion`:
  ```css
  @media (prefers-reduced-motion: reduce) {
    * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
  }
  ```
- Animate transforms and opacity (GPU-accelerated); avoid animating layout properties (width, height, top)
- Enter animations: ease-out (fast start, slow end)
- Exit animations: ease-in (slow start, fast end)
- No animation should delay user action

## Accessibility Quick Reference

### Keyboard Navigation

- All interactive elements focusable via Tab
- Logical focus order (matches visual order)
- Visible focus indicator (min 2px, 3:1 contrast)
- Escape closes modals/dropdowns
- Arrow keys for navigation within components (tabs, menus)

### Screen Readers

- Semantic HTML elements (`<nav>`, `<main>`, `<article>`, `<button>`)
- Meaningful alt text for images
- `aria-label` for icon-only buttons
- `aria-live` regions for dynamic content
- `aria-expanded` for collapsible content
- Skip navigation link as first focusable element

### Forms

- Every input has a visible `<label>` (or `aria-label`)
- Error messages linked to inputs via `aria-describedby`
- Required fields marked with `aria-required="true"`
- Form validation errors announced to screen readers

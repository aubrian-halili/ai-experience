# Playground Templates

## Base HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TITLE}}</title>
  <style>
    :root {
      --color-bg: #0f172a;
      --color-surface: #1e293b;
      --color-border: #334155;
      --color-text: #e2e8f0;
      --color-text-muted: #94a3b8;
      --color-primary: #3b82f6;
      --color-primary-hover: #2563eb;
      --color-success: #22c55e;
      --color-warning: #f59e0b;
      --color-danger: #ef4444;
      --radius: 8px;
      --spacing-xs: 4px;
      --spacing-sm: 8px;
      --spacing-md: 16px;
      --spacing-lg: 24px;
      --spacing-xl: 32px;
      --font-mono: 'SF Mono', 'Fira Code', monospace;
      --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: var(--font-sans);
      background: var(--color-bg);
      color: var(--color-text);
      min-height: 100vh;
      padding: var(--spacing-lg);
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
    }

    h1 { font-size: 1.5rem; margin-bottom: var(--spacing-lg); }

    .card {
      background: var(--color-surface);
      border: 1px solid var(--color-border);
      border-radius: var(--radius);
      padding: var(--spacing-lg);
      margin-bottom: var(--spacing-md);
    }

    button {
      background: var(--color-primary);
      color: white;
      border: none;
      padding: var(--spacing-sm) var(--spacing-md);
      border-radius: var(--radius);
      cursor: pointer;
      font-size: 0.875rem;
    }
    button:hover { background: var(--color-primary-hover); }

    input, select {
      background: var(--color-bg);
      color: var(--color-text);
      border: 1px solid var(--color-border);
      padding: var(--spacing-sm) var(--spacing-md);
      border-radius: var(--radius);
      font-size: 0.875rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>{{TITLE}}</h1>
    <!-- Content here -->
  </div>
  <script>
    // Interactivity here
  </script>
</body>
</html>
```

## Data Explorer Template

A table with search, sort, and filter capabilities:

- Filterable search input
- Sortable column headers (click to toggle asc/desc)
- Row count display
- Export to CSV button
- Responsive: horizontal scroll on small screens

**Layout:** Full-width table with toolbar above

## Concept Map Template

Draggable nodes with connection lines:

- Nodes positioned with CSS grid or absolute positioning
- SVG lines connecting related nodes
- Click to select, drag to reposition
- Double-click to edit node label
- Color-coded node categories

**Layout:** Full-viewport canvas area

## Component Showcase Template

Grid of UI components with interactive controls:

- Cards displaying component variations
- Control panel to adjust props (size, color, state)
- Code preview showing the current configuration
- Responsive grid that adapts to screen width

**Layout:** Sidebar controls + main grid area

## Dashboard Template

Multi-panel layout with metrics and charts:

- Top row: KPI cards with large numbers
- Middle: Chart area using CSS/SVG (no chart library)
- Bottom: Recent activity table
- Responsive: stacks to single column on mobile

**Layout:** CSS Grid with named areas

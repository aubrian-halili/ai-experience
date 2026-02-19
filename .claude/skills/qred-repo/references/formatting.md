# Formatting Reference

## Tree View Format

When presenting directory structures, use this indented format:

```
Qred/<repo>
+-- README.md
+-- package.json
+-- src/
|   +-- index.ts
|   +-- config/
|   |   +-- database.ts
|   |   +-- auth.ts
|   +-- routes/
|       +-- (...)
+-- tests/
|   +-- (...)
+-- docs/
    +-- architecture.md
```

- Use `+--` for entries and `|` for continuation lines
- Annotate key directories with brief descriptions when their purpose is clear (e.g., `src/ — application source`)
- Mark unexplored directories with `(...)` to indicate more content exists
- Respect the 3-level depth limit — show `(...)` for deeper levels

## Follow-up Suggestions by Layer

After each layer, suggest the natural next action:

| After Layer | Suggest |
|---|---|
| Orient | `tree <repo>` for structure overview, or search for specific terms |
| Navigate | Search for specific terms, or read a specific file |
| Search | Read the most relevant matching files, or narrow the search |
| Read | Related files, broader search, or navigate to parent directory |

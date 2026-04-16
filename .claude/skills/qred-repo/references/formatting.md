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
- Mark unexplored directories or truncated depth with `(...)`

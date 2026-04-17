---
name: doc-sync
description: >-
  User asks to "sync docs", "update CLAUDE.md", "audit project documentation",
  "check documentation drift", "is CLAUDE.md up to date", or "organize docs".
  Not for: reviewing code quality (use /review).
  Not for: Confluence wiki pages (use /confluence).
argument-hint: "[optional: --dry-run, --section <heading-name>]"
disable-model-invocation: true
allowed-tools: Bash(git log *, git diff *, git blame *, ls *, wc *), Read, Grep, Glob, Edit, Write
---

**Current branch:** !`git branch --show-current`
**Project root:** !`basename $(pwd)`
**CLAUDE.md:** !`test -f CLAUDE.md && echo "exists ($(wc -l < CLAUDE.md | tr -d ' ') lines)" || echo "missing"`
**Last CLAUDE.md commit:** !`git log -1 --format="%h %ar" -- CLAUDE.md 2>/dev/null || echo "untracked"`

Audit the project's full documentation surface for factual drift, broken references, and organizational issues — then apply targeted fixes. Works for any project type by parsing what documentation claims and verifying those claims against the filesystem and git history.

## Sync Philosophy

- **Derivable means deletable** — if a future session can figure it out by reading the code or running `ls`, it doesn't belong in CLAUDE.md; document the "why", not the "what"

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| `--dry-run` | Audit only, no edits | Run all checks, present findings, stop before Step 7 |
| `--section <heading>` | Audit one CLAUDE.md section only | Match `<heading>` against `## ` headings; scope all checks to that section |
| (none) | Full audit | Run all checks, present findings, apply confirmed edits |

## Process

### 1. Pre-flight

- Read `CLAUDE.md` into context (if present)
- Discover the full documentation surface:
  - `docs/` folder and subdirectories (Glob `docs/**/*.md`)
  - `.claude/rules/` modular instruction files (Glob `.claude/rules/*.md`)
  - Root-level markdown files (README.md, CONTRIBUTING.md, etc.)
  - Any `CLAUDE.md` files in subdirectories
- Build a **documentation inventory**: for each doc file found, note its tier (always-on / on-demand) and whether CLAUDE.md references it
- If `--section` is provided, match against actual `## ` headings

### 2. Project Discovery

Detect project type from marker files and existing doc conventions:

- **Monorepo signals**: multiple `package.json` / workspace config files, nested `CLAUDE.md` files

### 3. Claim Extraction & Verification

Parse all documentation files from the inventory and extract verifiable claims, then verify each against the filesystem. Claim types include numeric counts, file/directory paths, directory trees, command references, and cross-doc references.

### 4. Drift Detection

Use git history to find undocumented structural changes:

- `git log -1 --format="%ci" -- CLAUDE.md` to get CLAUDE.md's last commit date
- `git log --oneline --since="<that date>" --diff-filter=A --name-only` to find files added since then
- Focus on **structurally significant** additions: new top-level directories, new config files at root, new `index.*` / `main.*` / `app.*` files, new doc files in `docs/`
- Cross-reference additions against what CLAUDE.md describes — flag additions a future agent would benefit from knowing about

### 5. Documentation Organization Assessment

Evaluate how well the project's documentation is organized for Claude's context loading. See `@references/doc-organization.md` for the three-tier loading model.

**Flag these anti-patterns:**
- `CLAUDE.md` exceeds 200 lines — suggest extracting sections to `.claude/rules/` (conventions) or `docs/` (reference material) with a pointer
- Content in CLAUDE.md is derivable from config files (`package.json`, `go.mod`, etc.)
- Important conventions exist in `docs/` but not in `.claude/rules/` — they won't auto-load for every interaction
- `docs/` folder exists but CLAUDE.md has no pointer to it — agents won't know to look there
- Documentation duplicated across multiple files

**Note these good patterns** (no action needed):
- CLAUDE.md is lean (50–150 lines) and focused on "why" not "what"
- `.claude/rules/` used for always-applicable conventions
- `docs/` used for reference material with CLAUDE.md pointers

Organization findings are never auto-applied; always present them for confirmation.

### 6. Present Findings

Output a structured report before any edits with these categories:

- **Factual Errors** (will fix)
- **Drift Detected** (recommend fix)
- **Broken References**
- **Documentation Organization** (never auto-applied; always presented for confirmation)
- **Suggestions** (optional — skipped unless user confirms)

### 7. Apply Updates

- **5-line threshold** — if a finding requires more than 5 lines of change, flag for manual review instead of applying automatically

After edits, re-check CLAUDE.md line count: if edits pushed it over 200 lines, flag the new length and identify extraction candidates (sections that could move to `.claude/rules/` or `docs/`).

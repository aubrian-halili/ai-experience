---
name: project-sync
description: >-
  User asks to "sync docs", "update CLAUDE.md", "audit project documentation",
  "check documentation drift", "is CLAUDE.md up to date", or "organize docs".
  Not for: creating new skills (use /skill-creator) or reviewing code quality (use /review).
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

- **Accuracy over coverage** — fix factual errors before adding new content; a wrong count is worse than a missing paragraph
- **Derivable means deletable** — if a future session can figure it out by reading the code or running `ls`, it doesn't belong in CLAUDE.md; document the "why", not the "what"
- **Present findings before editing** — always show what you found and what you propose to change; never silently modify files
- **Targeted edits, not rewrites** — use Edit on specific lines; rewriting sections destroys intentional phrasing
- **Conservative by default** — when uncertain whether a finding warrants a change, skip it; the cost of clutter exceeds the cost of a missing note

## Input Handling

Use `$ARGUMENTS` if provided.

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
- Confirm git repo via `git log`; if `--section` is provided, match against actual `## ` headings

**Stop conditions:**
- `CLAUDE.md` does not exist → report and suggest creating one with project overview
- Not a git repo → skip drift detection, proceed with structural audit only and note the limitation
- `--section` names a heading not found in CLAUDE.md → list available headings and ask user to choose

### 2. Project Discovery

Detect project type and documentation conventions already in use:

- **Project type**: check for marker files (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle`, `.claude/skills/`)
- **Existing doc conventions**: ADR folders (`docs/architecture/decisions/`), API docs, changelog, contributing guides
- **Monorepo signals**: multiple `package.json` / workspace config files, nested `CLAUDE.md` files

Produces an internal project profile — not written anywhere. Used to contextualize findings (e.g., "this is a Node project" tells us to verify `package.json` script references).

### 3. Claim Extraction & Verification

Parse all documentation files from the inventory and extract verifiable claims. For each claim, verify it against the filesystem and report any discrepancy.

| Claim Type | Detection Pattern | Verification Method |
|------------|-------------------|---------------------|
| **Numeric counts** | `\d+\s+\w+` in structural context ("5 services", "3 rule files") | Count actual items via Glob/ls; compare |
| **File/directory paths** | Backtick-wrapped paths, inline paths matching `foo/bar.ext` | Verify each exists on filesystem |
| **Directory trees** | Fenced code blocks with `├──`, `└──`, `│` characters | Parse tree; verify each entry exists; check for unlisted siblings at same depth |
| **Command references** | Backtick commands (`` `npm test` ``, `` `make build` ``), `/slash-commands` | Verify scripts in package.json/Makefile, or skill directories |
| **Cross-doc references** | "see `docs/foo.md`", "defined in `.claude/rules/bar.md`" | Verify target file exists |
| **Convention file references** | Paths to config files (`.eslintrc`, `tsconfig.json`, `.prettierrc`) | Verify each exists |

Only flag claims where verification is definitive — skip claims that cannot be tested without running code.

### 4. Drift Detection

Use git history to find undocumented structural changes:

- `git log -1 --format="%ci" -- CLAUDE.md` to get CLAUDE.md's last commit date
- `git log --oneline --since="<that date>" --diff-filter=A --name-only` to find files added since then
- Focus on **structurally significant** additions: new top-level directories, new config files at root, new `index.*` / `main.*` / `app.*` files, new doc files in `docs/`
- Cross-reference additions against what CLAUDE.md describes — flag additions a future agent would benefit from knowing about

Skip individual source files unless they represent a new top-level module.

### 5. Documentation Organization Assessment

Evaluate how well the project's documentation is organized for Claude's context loading. See `@references/doc-organization.md` for the full best practices.

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

All organization findings go in the **Documentation Organization** category — never auto-applied; always presented for confirmation.

### 6. Present Findings

Output a structured report before any edits:

```
## Documentation Audit Report

### Factual Errors (will fix)
- [ ] CLAUDE.md line 14: says "5 agents" but 6 exist in .claude/agents/

### Drift Detected (recommend fix)
- [ ] src/payments/ directory added 3 commits after CLAUDE.md last updated; not mentioned

### Broken References
- [ ] docs/api.md line 22: references `src/routes/v2.ts` — file renamed to `src/routes/v2/index.ts`

### Documentation Organization
- [ ] CLAUDE.md is 280 lines — consider moving "API Reference" section (lines 120-210) to `docs/api-reference.md`
- [ ] `.claude/rules/` has no testing conventions — `docs/testing.md` would be more effective as `.claude/rules/testing.md`
- [ ] `docs/architecture/` exists but CLAUDE.md doesn't reference it

### Suggestions (optional — skipped unless you confirm)
- Consider documenting why the codebase uses a custom auth wrapper instead of the framework default

### No Action Needed
- All numeric counts are accurate
- All rule file references resolve
```

If `--dry-run`, stop here. Otherwise ask user to confirm before proceeding to Step 7.

### 7. Apply Updates

For each confirmed finding, use the appropriate tool:

- **Factual corrections** (`Edit`): update counts, paths, or references inline — match existing format and indentation
- **Drift updates** (`Edit`): append to relevant section using same style as existing entries
- **Documentation reorganization** (`Write`/`Edit`): present specific file moves/creates; get confirmation per file; execute with `Write` for new files and `Edit` for pointer additions
- **Never rewrite prose** — only correct factual claims; intentional phrasing is off-limits
- **5-line threshold** — if a finding requires more than 5 lines of change, flag for manual review instead of applying automatically

After edits, re-read modified files to confirm changes look correct.

## Output Principles

- **Report before edit** — the full findings report always precedes any file modification
- **Categorize by confidence** — Factual Errors (certain) vs. Drift (likely) vs. Suggestions (optional)
- **Cite evidence** — every finding references the file/line and the filesystem evidence that contradicts it
- **Project-agnostic evidence** — never assume a specific project structure; cite the actual path or git output
- **Minimal diff** — if a finding requires more than 5 lines of change, flag it for manual review

## Error Handling

| Scenario | Response |
|----------|----------|
| `CLAUDE.md` does not exist | Report; suggest creating one with project overview |
| No `docs/` or `.claude/rules/` | Note absence; suggest if project would benefit from them |
| Not a git repo | Skip drift detection; proceed with structural audit only; note limitation |
| Shallow clone (no history) | Skip drift detection; proceed with structural audit only |
| CLAUDE.md has no verifiable claims | Report; suggest adding structural information if project would benefit |
| CLAUDE.md has no `## ` section headings | Warn that audit is limited to count/reference checks; continue |
| Project type unrecognizable | Proceed with generic path/count verification; note limitation |
| CLAUDE.md very short (<10 lines) | Run possible checks; suggest expanding if it would help future agents |
| Monorepo with multiple CLAUDE.md files | Audit root only unless user specifies; note other locations |
| `--section` argument not found in CLAUDE.md | List available section headings; ask user to choose |
| Reorganization involves >10 file moves | Flag as large change; recommend manual review rather than auto-applying |
| User declines all proposed changes | Report "No changes made" and exit cleanly |

Never silently skip a check — surface what was checked, what was skipped, and why.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Planning new work; run `/project-sync` first so `/plan` has accurate context to explore |
| `/review` | Reviewing code quality, not documentation accuracy |
| `/verify` | Verifying implementation completeness against a plan |
| `/finish` | Wrapping up a branch; consider running `/project-sync` first |

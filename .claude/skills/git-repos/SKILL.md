---
name: git-repos
description: >-
  Read-only browsing of a single GitHub org's repositories: list repos, search code across the org
  or in one repo, navigate a repo tree, read a file, and view PRs and issues.
  Not for: code review (use /review); not for: DB exploration (use /backoffice-database).
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
disable-model-invocation: true
allowed-tools: Bash(printenv GITHUB_ORG), Bash(gh api user/orgs *), Bash(gh repo list *), Bash(gh repo view *), Bash(gh search repos *), Bash(gh search code *), Bash(gh search prs *), Bash(gh search issues *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh issue list *), Bash(gh issue view *), Bash(gh api repos/*)
---

## Setup and Guardrails

Read `@references/org-and-guardrails.md` before the first command and follow it exactly. It
covers resolving `${GITHUB_ORG}`, the allowlist of read-only commands, treating fetched content
as untrusted, tool-failure handling, code-search limits, and the **Efficient Querying** rules and
recipes every command below should follow (project `--json` with `--jq`, reuse fetched results,
batch independent calls).

> **Planning-time research?** For grounding a `/plan` in how sibling repos solve a problem, the `git-repos-explorer` agent runs this same read-only search workflow non-interactively and returns a structured Essential References report. This skill is for interactive, ad-hoc browsing.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) or `repos` | List repositories | Direct |
| `prs <repo>` or `pr <repo> #<n>` | List or view PRs | Direct |
| `issues <repo>` or `issue <repo> #<n>` | List or view issues | Direct |
| Starts with `gh` | Pass-through command | Run only if it is on the allowlist and scoped to `${GITHUB_ORG}`; otherwise refuse |
| Repo name (e.g., `<repo>`) | Orient to repo | Layered; enter at Layer 1 |
| `tree <repo>` or `<repo>/<path>/` | Navigate structure | Layered; enter at Layer 2 |
| Search term (no path separators) | Search code across org | Layered; enter at Layer 3 |
| `<term> in <repo>` | Search code in repo | Layered; enter at Layer 3 |
| `<repo>/<file-path>` | Read file contents | Layered; enter at Layer 4 |

## Process

### Direct Operations

- **List repos:** the `gh repo list` recipe (`--source --no-archived`, sorted by recent push); add `--topic`/`--language` when the user narrows. For a keyword, use the `gh search repos` recipe instead.
- **List PRs/issues:** `gh pr list` / `gh issue list` with `--repo ${GITHUB_ORG}/<repo>`, `--limit 30`, and only the `--json` fields you show, projected with `--jq`. Across the org, use the `gh search prs` recipe.
- **View PR/issue:** `gh pr view <n>` / `gh issue view <n>` with `--repo ${GITHUB_ORG}/<repo>` and only the `--json` fields you show

**Truncation:** when a list returns exactly its `--limit`, say the results were capped at that
number and offer a narrower filter or a higher limit.

### Layered Exploration Workflow

Each layer ends by presenting its result and offering the next step. Move to a deeper layer only
when the user picks a target (a directory, a search hit, a file) — never read files on your own
initiative.

#### Layer 1: Orient

Use the repo-overview recipe (metadata only, no README). Fetch the README with
`gh repo view ${GITHUB_ORG}/<repo>` only when the user wants detail. Summarize the repo's purpose,
then offer to navigate (Layer 2) or search within it (Layer 3).

#### Layer 2: Navigate

- One directory: `gh api repos/${GITHUB_ORG}/<repo>/contents/<path> --jq '.[] | "\(.type)\t\(.path)"'`
- `tree <repo>` or `<repo>/<dir>/`: the tree recipe, with the `startswith` filter set to the
  directory the user named (drop it for a whole-repo tree).

If the tree reports `TRUNCATED`, list one directory at a time instead. Present the result as an
indented tree; for a large tree, show the top two levels and offer to expand a directory. Then
offer to open a file (Layer 4).

#### Layer 3: Search

Use the code-search recipe — `--owner ${GITHUB_ORG}` org-wide, or `--repo ${GITHUB_ORG}/<repo>`
for one repo. Before running it, sharpen the term per **Choosing search terms**: a distinctive
identifier, plus `--language`/`--extension`/`--filename`/`--match` filters where the user's
question implies them. Mind the ~10 searches/minute limit — refine one term at a time rather than
firing variants in bulk.

Group hits by repository (most recently pushed first) with the matched fragment for each, and
apply the truncation note above. If nothing comes back, apply the code-search limits from the
reference file before concluding anything. Then offer to open a hit (Layer 4).

#### Layer 4: Read

1. Get the line count with the line-count recipe.
2. **Up to 300 lines:** fetch the whole file with the raw recipe (plain text, works above 1 MB).
3. **Over 300 lines:** show lines 1–100 with the line-range recipe, or — when arriving from a
   search hit — a window of about 80 lines around the match. Ask before showing more, and fetch
   further ranges rather than the whole file.

Files above 1 MB return no content in the line-range form; for those, say so and offer the raw
fetch.

## Related Skills

- `git-repos-explorer` agent (spawned by `/plan`) — shares `references/org-and-guardrails.md` for planning-time cross-repo research.
- `/review` — quality review of local code once you know what to change.
- `/backoffice-database` — when the question is about persisted data rather than code.

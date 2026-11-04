---
name: git-repos
description: >-
  Interactive, read-only browsing of a single GitHub org's repositories: list repos, search code
  across the org or in one repo, navigate a repo tree, read a file, and view PRs and issues. Use
  when the user wants to look something up in another org repo by hand.
  Not for: planning-time cross-repo research (the git-repos-explorer agent does that
  non-interactively); not for: code review (use /review); not for: DB exploration (use
  /backoffice-database).
argument-hint: "[repo name, file path, search term, tree <repo>, or gh command]"
disable-model-invocation: true
allowed-tools: Bash(printenv GITHUB_ORG), Bash(gh api user/orgs *), Bash(gh repo list *), Bash(gh repo view *), Bash(gh search repos *), Bash(gh search code *), Bash(gh search prs *), Bash(gh search issues *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh issue list *), Bash(gh issue view *), Bash(gh api repos/*)
---

## Setup and Guardrails

Read `@references/org-and-guardrails.md` before the first command and follow it exactly: org
resolution, the command allowlist, untrusted content, tool failure, code-search limits, and the
**Efficient Querying** rules and recipes that every command below uses.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) or `repos` | List repositories | Direct |
| `prs <repo>` or `pr <repo> #<n>` | List or view PRs | Direct |
| `issues <repo>` or `issue <repo> #<n>` | List or view issues | Direct |
| Starts with `gh` | Pass-through command | Run only if the reference's allowlist and rules permit it; otherwise refuse |
| Repo name (e.g., `<repo>`) | Orient to repo | Layered; enter at Layer 1 |
| `tree <repo>` or `<repo>/<path>/` | Navigate structure | Layered; enter at Layer 2 |
| Search term (no path separators) | Search code across org | Layered; enter at Layer 3 |
| `<term> in <repo>` | Search code in repo | Layered; enter at Layer 3 |
| `<repo>/<file-path>` | Read file contents | Layered; enter at Layer 4 |

## Process

### Direct Operations

- **List repos:** the `gh repo list` recipe; add `--topic`/`--language` when the user narrows. For
  a keyword, use the `gh search repos` recipe instead.
- **List PRs/issues:** `gh pr list` / `gh issue list` with `--repo ${GITHUB_ORG}/<repo>` and
  `--limit 30`. Across the org, use the `gh search prs` recipe.
- **View PR/issue:** `gh pr view <n>` / `gh issue view <n>` with `--repo ${GITHUB_ORG}/<repo>`.

**Truncation:** when a list returns exactly its `--limit`, say the results were capped at that
number and offer a narrower filter or a higher limit.

### Layered Exploration Workflow

Each layer ends by presenting its result and offering the next step: Layer 1 → 2 or 3; Layers 2
and 3 → 4. Go deeper only when the user picks a target (a directory, a search hit, a file) —
never read files on your own initiative.

#### Layer 1: Orient

Run the repo-overview recipe and summarize the repo's purpose. Fetch the README with
`gh repo view ${GITHUB_ORG}/<repo>` only when the user wants detail.

#### Layer 2: Navigate

- One directory: `gh api repos/${GITHUB_ORG}/<repo>/contents/<path> --jq '.[] | "\(.type)\t\(.path)"'`
- `tree <repo>` or `<repo>/<dir>/`: the tree recipe, with the `startswith` filter set to the
  directory the user named.

Present the result as an indented tree; for a large tree, show the top two levels and offer to
expand a directory.

#### Layer 3: Search

Run the code-search recipe — `--owner ${GITHUB_ORG}` org-wide, or `--repo ${GITHUB_ORG}/<repo>`
for one repo — after sharpening the term per **Choosing search terms**. Because of the rate
limit, refine one term at a time rather than firing variants in bulk.

Group hits by repository with the matched fragment for each, and apply the truncation note above.

#### Layer 4: Read

1. Get the line count with the line-count recipe. On `TOO_LARGE`, the file is over 1 MB and the
   line-range form returns nothing: say so and offer the raw fetch.
2. **Up to 300 lines:** fetch the whole file with the raw recipe.
3. **Over 300 lines:** show lines 1–100 with the line-range recipe, or — when arriving from a
   search hit — a window of about 80 lines around the match. Ask before showing more, and fetch
   further ranges rather than the whole file.

## Related Skills

- `git-repos-explorer` agent (spawned by `/plan`) — the same read-only workflow, run
  non-interactively for planning-time research; shares `references/org-and-guardrails.md`.
- `/review` — quality review of local code once you know what to change.
- `/backoffice-database` — when the question is about persisted data rather than code.

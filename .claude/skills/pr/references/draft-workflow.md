# Draft PR Workflow

Reference for working with draft pull requests.

## When to Use Draft PRs

- Work-in-progress needing early feedback
- Changes not ready for merge
- Triggering CI before final review
- Collaborative development with multiple contributors

## Creating Draft PRs

```bash
# Create a draft PR — populate --body from the appropriate template file
gh pr create --draft --title "<TICKET-ID> <type>(<scope>): <description>" --body "$(cat <<'EOF'
<body from minor-template.md or major-template.md or frontend-minor-template.md or frontend-major-template.md>
EOF
)"
```

## Marking Ready for Review

When the PR is ready:

```bash
# Mark draft as ready for review
gh pr ready

# Or with PR number
gh pr ready 123
```

## Draft PR Conventions

**Title format:** Follow the standard convention — `<TICKET-ID> <type>(<scope>): <description>`. Draft status is communicated via the GitHub draft flag, not a title prefix. Use `--ready` (or `gh pr ready`) to promote to ready for review.

**Description:**
- Include a status section indicating what's done/remaining
- Use checkboxes for tracking progress

## Converting Existing PR to Draft

```bash
# Convert published PR back to draft
gh pr ready --undo

# Or with PR number
gh pr ready 123 --undo
```

## CI with Draft PRs

Draft PRs still trigger CI workflows, allowing you to:
- Validate changes before requesting review
- Catch issues early in development
- Run automated tests on work-in-progress

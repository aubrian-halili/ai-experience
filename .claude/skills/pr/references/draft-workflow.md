# Draft PR Workflow

Reference for working with draft pull requests.

## When to Use Draft PRs

- Work-in-progress needing early feedback
- Changes not ready for merge
- Triggering CI before final review
- Collaborative development with multiple contributors

## Creating Draft PRs

```bash
# Create draft PR
gh pr create --draft --title "UN-1234 WIP: Add authentication" --body "$(cat <<'EOF'
## Jira
UN-1234

## Summary
- Initial implementation of auth flow
- Still need to add tests

## Status
🚧 Work in progress - not ready for review

## Test plan
- [ ] Unit tests
- [ ] Integration tests

## Type of Change
- [ ] Non-functional / internal
- [ ] Minor change in our product (no or very low risk change)
- [ ] Documentation or comments
- [ ] Dev tooling / config
- [ ] Logging improvement
- [ ] Dependency update (non-breaking)
- [ ] Improving QEMM level(s)

## Checklist for pull request author
- [ ] No impact on runtime logic or API behavior
- [ ] Code builds successfully
- [ ] All tests pass locally
- [ ] No environment changes required
- [ ] I have reviewed the Qred score card results and acted on them
- [ ] Linked to relevant internal task/ticket (if applicable)
- I used agentic / vibe -coding for (only choose one)
  - [ ]  for mainly building this feature
  - [ ]  for partly building this feature
  - [ ]  for documentation / testing this feature

## Checklist for reviewers
- [ ] Change verified in **test environment**
- [ ] I have reviewed the Qred score card results and acted or feedbacked on them
- [ ] This change does not seem to have any potential risks to expose data
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

**Title prefix:**
- Use `WIP:` or `Draft:` prefix for clarity
- Example: `UN-1234 WIP: Add user authentication`

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

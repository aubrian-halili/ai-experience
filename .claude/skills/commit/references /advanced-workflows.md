# Advanced Git Workflows

Reference for multi-commit and advanced git workflows.

## Atomic Commits

When changes span multiple concerns, split into separate commits — one per logical unit (config, feature, tests).

## Squash Before PR

Interactive rebase (`git rebase -i`) requires manual terminal input and is not supported in Claude Code. Instead:

- Use GitHub's squash merge option when merging the PR
- Or manually squash in your terminal outside of Claude Code

```bash
# Squash merge when merging PR (recommended)
gh pr merge --squash
```

## Breaking Changes

For commits with breaking changes:

```
UN-1234 feat(api)!: change response format

BREAKING CHANGE: Response now returns array instead of object
```

## Large Changesets

When working with large changesets, identify logical units and commit incrementally — each commit should be atomic and buildable.

## Amending Commits

```bash
# Amend last commit message
git commit --amend -m "UN-1234 feat: corrected message"

# Add forgotten files to last commit
git add forgotten-file.ts
git commit --amend --no-edit
```

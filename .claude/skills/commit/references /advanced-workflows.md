# Advanced Git Workflows

Reference for multi-commit and advanced git workflows.

## Atomic Commits

When changes span multiple concerns, split into separate commits:

```bash
# Commit 1: Infrastructure change
git add src/config/
git commit -m "UN-1234 chore: update database configuration"

# Commit 2: Feature implementation
git add src/services/ src/api/
git commit -m "UN-1234 feat: add user preferences service"

# Commit 3: Tests
git add tests/
git commit -m "UN-1234 test: add preferences service coverage"
```

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

When working with large changesets:

1. **Identify logical units** - Group related changes
2. **Commit incrementally** - Each commit should be atomic and buildable
3. **Keep commits focused** - One concern per commit
4. **Write clear messages** - Future you will thank present you

## Amending Commits

```bash
# Amend last commit message
git commit --amend -m "UN-1234 feat: corrected message"

# Add forgotten files to last commit
git add forgotten-file.ts
git commit --amend --no-edit
```

**Warning:** Never amend commits that have been pushed to a shared branch.

# Advanced Git Workflows

## Squash Before PR

Interactive rebase (`git rebase -i`) requires manual terminal input and is not supported in Claude Code. Instead:

- Use GitHub's squash merge option when merging the PR
- Or manually squash in your terminal outside of Claude Code

```bash
# Squash merge when merging PR (recommended)
gh pr merge --squash
```

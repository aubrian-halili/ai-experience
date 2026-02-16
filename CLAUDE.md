# Project Conventions

## Git Conventions

### Branch Naming

Branches must be prefixed with the Jira ticket ID:

`<JIRA-ID>-<feature-description>`

Example: `UN-1234-add-user-auth`

- Always ask for the Jira ticket ID before creating a new branch
- Never create a branch without the Jira ticket ID prefix

### Commit Messages

Every commit message must start with the Jira ticket ID:

`<JIRA-ID> <type>(<scope>): <description>`

- Extract the Jira ticket ID from the current branch name — do not ask the user for it
- If the branch name does not contain a Jira ticket ID, ask for one before committing
- Never create a commit without the Jira ticket ID prefix
- Never commit directly to main/master

**Types**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

## Code Style

- Use TypeScript unless otherwise specified
- Use `mermaid` code blocks for diagrams

# Frontend Minor PR Body Template

## Template

```
## Summary
- Bullet points from commit messages

## Jira
[<TICKET-ID>](https://qredab.atlassian.net/browse/<TICKET-ID>)

## Breaking Changes
- None / List breaking changes

## Test Plan
- Verification steps

## Type of Change
- [ ] Non-functional / internal
- [ ] Minor front-end update (no or very low risk change)
- [ ] Documentation or comments
- [ ] Dev tooling / config
- [ ] Dependency update (non-breaking)

- [ ] New feature
- [ ] Feature enhancement
- [ ] Bugfix
- [ ] UI/UX improvement
- [ ] Performance optimization
- [ ] Security fix

## Checklist for pull request author
- [ ] I used agentic / vibe-coding for (only choose one)
  - [ ] for mainly building this feature
  - [ ] for partly building this feature
  - [ ] for documentation / testing this feature

- [ ] No impact on runtime logic or API behavior
- [ ] No environment changes required
- [ ] Linked to relevant internal task/ticket (if applicable)

- [ ] Change verified in **test environment**
- [ ] Tested by the **product manager** as of defined high-level tests in Discovery document
- [ ] Breaking change but there is mitigation plan for affected teams/services documented in PR.
- [ ] Test coverage is adequate for the affected flows
- [ ] Code reviewed by at least **one other developer**
- [ ] Adheres to front-end coding and design guidelines
- [ ] Linked to relevant internal task/ticket
- [ ] I have extracted relevant tests from internal task/ticket/discovery in Ticket ID section

## Checklist for reviewers
- [ ] Change verified in **test environment**

- [ ] This change does not seem to have any potential risks to expose data

- [ ] I have come up with relevant scenarios to test and stated them in a comment of this PR
- [ ] I have reviewed the Qred scorecard results and acted on them
- [ ] I have reviewed for any relevant security exposures or changes
```

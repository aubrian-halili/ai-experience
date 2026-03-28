# Frontend Major PR Body Template

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
- [ ] Breaking change
- [ ] Configuration update
- [ ] Documentation
- [ ] High-impact performance update
- [ ] Major feature or architectural refactor
- [ ] New feature

## Impact Assessment
- [ ] Change may affect multiple screens/components
- [ ] Requires thorough manual testing
- [ ] May require database/API considerations (if applicable)
- [ ] Major user workflow change
- [ ] Business major functionality affected
- [ ] Requires coordinated release

## Checklist for pull request author
- [ ] Full unit and other automated tests added or updated
- [ ] Manual testing completed for all affected flows
- [ ] Code reviewed by at least **two peers** one of which is a **tech lead**
- [ ] Tested by the **product manager or stakeholder(s)** as of defined high-level tests in NPAP OR Discovery document
- [ ] UI/UX review completed if applicable
- [ ] Conforms to front-end style guide
- [ ] Linked to relevant internal task/ticket
- [ ] Documented any breaking changes or migration steps
- [ ] Rollback strategy prepared and documented <!-- can be feature flagging or purely rollback instructions -->
- [ ] I have extracted relevant tests from internal task/ticket/discovery in Ticket ID section
- [ ] I have reviewed the Qred scorecard results and acted on them
- [ ] I used agentic / vibe-coding for (only choose one)
  - [ ] for mainly building this feature
  - [ ] for partly building this feature
  - [ ] for documentation / testing this feature

## Checklist for reviewers
- [ ] Change verified in **test environment**
- [ ] Verified rollback documentation or strategy
- [ ] I have verified that existing test coverage is adequate for the affected flows
- [ ] I have reviewed for any relevant security exposures or changes
```

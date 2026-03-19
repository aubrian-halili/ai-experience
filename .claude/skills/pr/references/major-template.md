# Major PR Body Template

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

## Checklist
- [ ] Code reviewed by **tech lead (or architect)**
- [ ] Change verified in **test environment**
- [ ] Tested by the **product manager or stakeholder(s)** as of defined highlevel tests in NPAP OR Discovery document
- [ ] Rollback strategy prepared and documented <!-- can be feature flagging or purely rollback instructions -->
- [ ] Monitoring/alerting updated as needed
- [ ] Database or infrastructure migrations tested <!--only if relevant -->
- [ ] Linked to relevant internal task/ticket
- [ ] I have extracted relevant tests from internal task/ticket/discovery in Ticket ID section
- [ ] Code is meeting Advanced level of Test & Quality + Monitoring & Observability in QEMM
- [ ] I looked and acted at the sonarqube quality gate feedback
- I used agentic / vibe-coding for (only choose one):
  - [ ] for mainly building this feature
  - [ ] for partly building this feature
  - [ ] for documentation / testing this feature

## Checklist for reviewers
- [ ] Change verified in **test environment**
- [ ] Verified rollback documentation or strategy
- [ ] Code is meeting Advanced level of Test & Quality + Monitoring & Observability in QEMM
- [ ] I have come up with a few new scenarios to test and stated them in a comment of this PR
- [ ] I have reviewed the Qred score card results and acted on them
- [ ] I have reviewed for any relevant security exposures or changes
```

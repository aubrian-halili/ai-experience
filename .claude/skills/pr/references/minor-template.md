# Minor PR Body Template

## Template

```
## Summary
- Bullet points from commit messages

## Jira
<TICKET-ID>

## Breaking Changes
- None / List breaking changes

## Test Plan
- Verification steps

## Type of Change
- [ ] New third party integration
- [ ] New feature
- [ ] Architectural adjustments
- [ ] Minor change of business process or logic
- [ ] Security fix

## Checklist
- [ ] Change verified in **test environment**
- [ ] Tested by the **product manager** as of defined highlevel tests in Discovery document
- [ ] No breaking change
- [ ] Breaking change but there is mitigation plan for affected teams/services documented in PR. 
- [ ] Unit and/or integration tests updated as needed
- [ ] Logging and error handling verified
- [ ] Linked to relevant internal task/ticket
- [ ] Rollback strategy prepared and documented if there is external customer impact <!-- can be feature flagging or purely rollback instructions -->
- [ ] Monitoring/alerting updated as needed
- [ ] I have extracted relevant tests from internal task/ticket/discovery in Ticket ID section
- [ ] Code is meeting Advanced level of Test & Quality + Monitoring & Observability in QEMM
- [ ] I looked and acted at the sonarqube quality gate feedback
- I used agentic / vibe -coding for (only choose one)
  - [ ]  for mainly building this feature
  - [ ]  for partly building this feature
  - [ ]  for documentation / testing this feature

## Checklist for reviewers
- [ ] Change verified in **test environment**
- [ ] Verified rollback documentation or strategy
- [ ] Code is meeting Advanced level of Test & Quality + Monitoring & Observability in QEMM
- [ ] I have come up with relevant scenarios to test and stated them in a comment of this PR
- [ ] I have reviewed the Qred score card results and acted on them
- [ ] I have reviewed for any relevant security exposures or changes
```

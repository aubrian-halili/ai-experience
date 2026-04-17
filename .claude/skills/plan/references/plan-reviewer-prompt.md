# Plan Reviewer Checklist

Use this checklist to validate a plan before presenting it to the user.

## Verifiability

- [ ] Every phase has a verification section with runnable commands or checkable conditions
- [ ] Verification steps have expected outputs, not just "run the tests"

## Granularity

- [ ] Each phase is small enough to execute independently by a fresh agent
- [ ] Each phase matches the Project Plan Template structure (files to create/modify, verification)

## Scope

- [ ] Plan does not span multiple independent subsystems without justification
- [ ] Each phase produces independently testable software

## Coherence

- [ ] All observable truths from "Define Done" are covered by at least one phase

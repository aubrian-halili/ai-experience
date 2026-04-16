# Plan Reviewer Checklist

Use this checklist to validate a plan before presenting it to the user.

## Verifiability

- [ ] Every phase has a verification section with runnable commands or checkable conditions
- [ ] Verification steps have expected outputs, not just "run the tests"
- [ ] No verification step relies on subjective judgment ("looks correct", "works properly")

## Granularity

- [ ] Each task is completable in 2-5 minutes by a fresh agent
- [ ] No task requires reading more than 5 files to understand scope
- [ ] Each task specifies: exact file path, what to write/modify, verification command with expected output

## Scope

- [ ] Plan does not span multiple independent subsystems without justification
- [ ] Each phase produces independently testable software
- [ ] Plan is under 1000 lines — if longer, split into phase documents

## Coherence

- [ ] All observable truths from "Define Done" are covered by at least one phase

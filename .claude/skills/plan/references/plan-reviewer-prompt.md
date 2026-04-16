# Plan Reviewer Checklist

Use this checklist to validate a plan before presenting it to the user. Every check must pass — if any fails, revise the plan before proceeding.

## Completeness

- [ ] Every task has specific file paths, not vague references like "the config file" or "the main module"
- [ ] Every task specifies what to write or modify, not just which file to touch

## Verifiability

- [ ] Every phase has a verification section with runnable commands or checkable conditions
- [ ] Verification steps have expected outputs, not just "run the tests"
- [ ] No verification step relies on subjective judgment ("looks correct", "works properly")

## Granularity

- [ ] Each task is completable in 2-5 minutes by a fresh agent
- [ ] No task requires reading more than 5 files to understand scope
- [ ] Each task specifies: exact file path, what to write/modify, verification command with expected output

## File Architecture

- [ ] No file is planned to hold multiple unrelated responsibilities
- [ ] New files follow existing codebase conventions and patterns
- [ ] Files that change together are grouped by responsibility, not technical layer

## Scope

- [ ] Plan does not span multiple independent subsystems without justification
- [ ] Each phase produces independently testable software
- [ ] Plan is under 1000 lines — if longer, split into phase documents

## Coherence

- [ ] All observable truths from "Define Done" are covered by at least one phase
- [ ] No phase lacks a clear connection to at least one observable truth
- [ ] Dependencies between phases are explicit and acyclic
- [ ] Phase ordering follows the dependency graph, not arbitrary sequencing

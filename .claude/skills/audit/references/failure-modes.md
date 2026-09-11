# Failure Modes

The recurring ways a confident answer turns out wrong. Each entry is a hunt to run, not a caution to
recite.

## Single-vector undercount

The original answer searched one term and stopped. Re-search with:

- **Synonyms and house style** — `client`, `adapter`, `gateway`, `connector`, `provider`, `sdk`,
  `service`, `api` — plus whatever the repo actually calls the concept.
- **The other end of the wire** — a call site found by HTTP verb, base URL, or hostname rather than
  by class name.
- **Non-code declarations** — env var names, `pyproject.toml` / `package.json` dependencies,
  Terraform and CDK resources, OpenAPI specs, secret names in Secrets Manager.
- **Indirect paths** — generated clients, dynamic dispatch, registries populated at import time,
  string-keyed factories.

## Boundary ambiguity

The count changes depending on an unstated rule. Name the rule explicitly and report the count under
it: inbound vs outbound; first-party vs third-party; active vs commented-out, feature-flagged, or
dead; production vs test fixtures and mocks; one integration per vendor vs per endpoint.

## Stale or misread evidence

- The cited `file:line` no longer says what the answer claimed — re-read it rather than trusting the
  quote.
- The evidence came from a summary, a comment, or a README instead of the code. Re-derive it from
  the code and note any divergence.
- The branch moved. Confirm which revision the evidence was read at.

## Closure asserted but never tested

The answer listed members and implied nothing else qualifies, without a search that *could* have
falsified it. The closure claim needs its own evidence: a search broad enough to have returned a
fifth member if one existed.

## Question drift

The answer resolves a nearby but different question — how many integrations *are configured* vs *are
called*, what the code *should* do vs *does*.

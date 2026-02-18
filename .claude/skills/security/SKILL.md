---
name: security
description: Use when the user asks to "review security", "check for vulnerabilities", "security audit", "threat model", mentions "OWASP", "XSS", "SQL injection", "authentication security", or needs security guidance and vulnerability assessment.
argument-hint: "[file, component, or feature to assess]"
allowed-tools: Read, Grep, Glob
---

Provide comprehensive security guidance, vulnerability assessment, and secure-by-design recommendations.

## When to Use

### This Skill Is For

- Security audits of code or architecture
- Vulnerability identification and remediation
- Threat modeling for features or systems
- Secure coding guidance and best practices
- Security review checklists
- Authentication/authorization design review

### Use a Different Approach When

- General code quality review without security focus → use `/review`
- Architecture design without specific security concerns → use `/architecture`
- Compliance documentation → consult compliance specialists

## Input Classification

Use `$ARGUMENTS` if provided (file path, component name, or feature to assess).

First, classify the security assessment type:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Code Audit** | "check this code", "review for vulnerabilities" | Line-by-line security analysis |
| **Threat Model** | "threat model", "attack surface", "risk assessment" | STRIDE/DREAD analysis |
| **Design Review** | "is this secure", "security architecture" | Security pattern evaluation |
| **Remediation** | "fix this vulnerability", "secure this" | Targeted hardening guidance |
| **Checklist** | "security checklist", "pre-deploy check" | Systematic verification |

## Process

### 1. Scope Definition

Identify what to assess: specific files/functions, auth flows, data handling, external integrations, or infrastructure configuration.

### 2. Threat Identification

Use STRIDE threat model to identify threats (see `@references/frameworks.md`).

### 3. Vulnerability Assessment

Check against OWASP Top 10 (see `@references/frameworks.md`).

### 4. Risk Scoring

Use DREAD for severity assessment (see `@references/frameworks.md`).

### 5. Remediation Recommendations

For each finding, provide clear vulnerability description, potential impact, specific code fix with before/after examples, and defense-in-depth recommendations.

See `@references/templates.md` for full response structure.
See `@references/checklists.md` for specialized security checklists (API, Authentication, Data Protection, Dependencies).

## Error Handling

| Scenario | Response |
|----------|----------|
| Cannot access target files | List what was reviewed, note gaps |
| Complex vulnerability found | Flag for manual security review |
| Uncertainty about severity | Default to higher severity, note uncertainty |
| No vulnerabilities found | State clean bill with confidence level |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | General code review with security as one dimension |
| `/architecture` | Security architecture design from scratch |
| `/patterns` | Implementing specific security patterns |
| `/architecture --adr` | Documenting security architecture decisions |

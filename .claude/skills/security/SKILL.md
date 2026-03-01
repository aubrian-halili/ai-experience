---
name: security
description: Use when the user asks to "review security", "check for vulnerabilities", "security audit", "threat model", mentions "OWASP", "XSS", "SQL injection", "authentication security", or needs security guidance and vulnerability assessment.
argument-hint: "[file, component, or feature to assess]"
allowed-tools: Read, Grep, Glob
---

Provide comprehensive security guidance, vulnerability assessment, and secure-by-design recommendations.

## Security Philosophy

- **Defense in depth** — assess multiple security layers; a single control failure should not mean full compromise
- **Assume breach** — evaluate what happens when a control fails, not just whether it exists
- **Least privilege** — verify that code and configurations request minimum necessary access
- **Scope before depth** — define assessment boundaries first; thorough analysis of a focused area beats shallow coverage of everything
- **Practical remediation** — every finding must include a concrete fix; identifying vulnerabilities without actionable guidance wastes effort

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

Classify `$ARGUMENTS` to determine the assessment scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Assess security of current scope | Ask user to specify target |
| File path (e.g., `src/auth/login.ts`) | Audit specific file | Code-level vulnerability scan |
| Directory path (e.g., `src/auth/`) | Audit directory files | Systematic directory analysis |
| Component name (e.g., `AuthService`) | Audit component security | Locate component, assess matches |
| Feature description (e.g., `payment flow`) | Trace and assess feature | End-to-end security analysis |
| Checklist request (e.g., `API checklist`) | Run security checklist | Apply checklist from `@references/checklists.md` |

## Process

### 1. Pre-flight

- Classify assessment scope from `$ARGUMENTS` using the Input Classification table
- Verify target files/components exist and are readable
- For file-based audits: confirm files exist via Glob, read target code
- For component/feature assessments: locate relevant files via Grep
- Check for CLAUDE.md conventions and project-specific security requirements

**Stop conditions:**
- Target files not found → report missing paths, ask user to verify
- No `$ARGUMENTS` and no obvious assessment target → ask user to specify scope
- Target is outside the codebase (infrastructure, cloud config) → note limitation, recommend specialized tools

### 2. Define Scope

- Identify assessment boundaries: specific files/functions, auth flows, data handling, external integrations, or infrastructure configuration
- Map trust boundaries — where does untrusted input enter the system?
- Identify sensitive data flows (credentials, PII, tokens)
- Note which OWASP categories are most relevant to the target

### 3. Identify Threats

Apply STRIDE threat model to the scoped target (see `@references/frameworks.md`):

1. Map each STRIDE category against the identified trust boundaries
2. For each applicable threat, document the attack vector and affected component
3. Prioritize threats by likelihood and impact

### 4. Assess Vulnerabilities

Check target against OWASP Top 10 (see `@references/frameworks.md`):

1. Systematically evaluate each relevant OWASP category
2. For code audits: trace data flow from input to output, flag unsafe operations
3. For design reviews: evaluate security patterns and missing controls
4. Cross-reference with applicable checklists from `@references/checklists.md`

### 5. Score Risks

Use DREAD for severity assessment (see `@references/frameworks.md`):

1. Score each finding across all 5 DREAD factors (1–3 scale)
2. Calculate composite score (Sum / 5)
3. Classify: Low (1–2), Medium (2–3), High (3+)
4. Prioritize findings by composite score descending

### 6. Report Findings

Present findings using the Security Assessment template from `@references/templates.md`.

For each finding, provide:
- Clear vulnerability description with OWASP category reference
- DREAD score breakdown
- Potential impact and exploitability
- Specific code fix with before/after diff examples
- Defense-in-depth recommendations

**No findings case:** If assessment produces no vulnerabilities, explicitly state: "No vulnerabilities identified in the assessed scope. Confidence level: [High/Medium/Low] based on coverage of [X of 10] OWASP categories."

### 7. Verify

- Confirm all trust boundaries and OWASP categories in scope were evaluated; note any skipped with rationale
- Verify every finding includes a DREAD score, OWASP category reference, and concrete remediation
- Sanity-check severity distribution — if all findings are High or all are Low, re-evaluate scoring consistency
- Suggest next steps: recommend related skills, manual pen testing, or state security clearance with confidence level

## Output Principles

- **Severity-first ordering** — group findings by DREAD score (High first), not by file or OWASP category
- **Attack narrative** — describe each finding as an attack scenario: who, how, what impact
- **Actionable remediation** — provide concrete code fixes with diff examples for High and Critical findings
- **Defense in depth** — for every finding, suggest at least one additional layer of protection beyond the primary fix

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user to specify scope; suggest scanning recently changed files |
| File path (e.g., `src/auth/login.ts`) | Code audit of the specific file |
| Directory path (e.g., `src/auth/`) | Code audit of all files in directory |
| Component name (e.g., `AuthService`) | Locate component files via Grep, audit matching files |
| Feature description (e.g., `payment flow`) | Trace feature across codebase, assess end-to-end security |
| Checklist request (e.g., `API checklist`) | Run specific checklist from `@references/checklists.md` |

## Error Handling

| Scenario | Response |
|----------|----------|
| Target files not found | Report missing paths, ask user to verify |
| Cannot access target files | List what was reviewed, note gaps in coverage |
| Scope too broad (>50 files) | Prioritize by trust boundaries and data sensitivity, note coverage gaps |
| Complex vulnerability found | Flag for manual security review by a security specialist |
| Uncertainty about severity | Default to higher severity, note uncertainty with reasoning |
| No vulnerabilities found | State clean bill with confidence level and coverage scope |
| Vulnerability requires runtime testing | Note limitation, recommend DAST tools or manual penetration testing |
| Third-party dependency vulnerability | Reference `npm audit` / `pip-audit` / `cargo audit`, recommend version pinning |

Never silently skip OWASP categories or trust boundaries — surface assessment coverage and limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | General code review with security as one dimension |
| `/architecture` | Security architecture design from scratch |
| `/patterns` | Implementing specific security patterns |
| `/explore` | Understand codebase context before auditing unfamiliar code |
| `/clean-code` | Code quality issues unrelated to security |

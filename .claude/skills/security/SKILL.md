---
name: security
description: >-
  User asks for "security review", "security audit", "threat model",
  mentions OWASP, XSS, SQL injection, or asks "is this secure".
  Not for: general code review (use /review), code quality refactoring
  (use /clean-code), IAM/cloud security (use /aws).
argument-hint: "[file, component, or feature to assess]"
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Agent, Bash(npx semgrep *, npm audit *, pip-audit *, cargo audit *)
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

Check target against OWASP Top 10 (see `@references/frameworks.md`).

**For large codebases (>10 files in scope):** Dispatch parallel `security-scanner` agents (from `.claude/agents/security-scanner.md`) to cover threat categories concurrently. Launch these agents simultaneously using the Agent tool, passing each a specific threat category and file scope:

| Agent | Threat Category | What to scan |
|-------|----------------|-------------|
| **security-scanner** (Injection & Input) | A01 Injection, A03 Injection | SQL/NoSQL injection, XSS, command injection, SSRF, input validation gaps |
| **security-scanner** (Auth & Access) | A01 Broken Access Control, A07 Auth Failures | Authentication flows, authorization checks, session management, privilege escalation |
| **security-scanner** (Data & Crypto) | A02 Cryptographic Failures, A04 Insecure Design | Secrets in code, weak hashing, plaintext storage, insecure data transmission |
| **security-scanner** (Config & Dependencies) | A05 Security Misconfiguration, A06 Vulnerable Components | Dependency CVEs, debug modes, default credentials, overly permissive CORS/headers |

Each `security-scanner` agent returns: findings with file:line locations, OWASP category, and severity estimate. Merge and deduplicate results before scoring.

**For smaller scopes (<10 files):** Perform sequential analysis without subagents:

1. Systematically evaluate each relevant OWASP category
2. For code audits: trace data flow from input to output, flag unsafe operations
3. For design reviews: evaluate security patterns and missing controls
4. Cross-reference with applicable checklists from `@references/checklists.md`

### 4.5. Automated Scanning (When Available)

Run available static analysis and dependency audit tools to complement manual review:

**Static Analysis (if installed):**
- Run Semgrep with relevant rulesets: `npx semgrep --config auto <target-path>`
- Cross-reference Semgrep findings with manual findings; deduplicate

**Dependency Audit (language-specific):**
| Ecosystem | Command | Focus |
|-----------|---------|-------|
| Node.js | `npm audit` | Known CVEs in dependencies |
| Python | `pip-audit` | Known CVEs in packages |
| Rust | `cargo audit` | Known CVEs in crates |

**Integration rules:**
- Tool findings supplement but do not replace manual OWASP analysis
- If tools are not installed, note their absence and recommend installation
- Deduplicate: if a tool finding overlaps with a manual finding, merge them and note both sources

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
| `/testing` | Write security-focused tests after audit |

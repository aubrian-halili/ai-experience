# Security

## Philosophy

- **Defense in depth** — a single control failure should not mean full compromise
- **Assume breach** — evaluate what happens when a control fails
- **Least privilege** — code and configs request minimum necessary access

## Assessment Process

1. **Scope** — map trust boundaries and identify where untrusted input enters
2. **STRIDE** — apply threat model: Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege
3. **OWASP Top 10** — check against all 10 categories; note any skipped with rationale
4. **DREAD Scoring** — score each finding: Damage, Reproducibility, Exploitability, Affected users, Discoverability (1–3 scale; average ≥ 2.5 = High)
5. **Parallel agents** — for large codebases (>10 files), dispatch `security-scanner` subagents by category: Injection, Auth/Access, Data/Crypto, Config/Dependencies

## Output Format

- Group findings by severity (High first)
- Each finding: OWASP category, DREAD score, attack narrative, concrete before/after fix
- If no findings: state confidence level and OWASP categories covered

## Automated Tools

Run when available: `npx semgrep --config auto <target>`, `npm audit`, `pip-audit`, `cargo audit`

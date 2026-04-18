# Security

## Assessment Process

1. **Scope** — map trust boundaries and identify where untrusted input enters
2. **STRIDE** — apply the threat model
3. **OWASP Top 10** — note any categories skipped with rationale
4. **DREAD Scoring** — score each finding on a 1–3 scale; average ≥ 2.5 = High
5. **Parallel agents** — for large codebases (>10 files), dispatch `security-scanner` subagents by category: Injection, Auth/Access, Data/Crypto, Config/Dependencies

## Output Format

- Group findings by severity (High first)
- Each finding: OWASP category, DREAD score, attack narrative, concrete before/after fix
- If no findings: state confidence level and OWASP categories covered

## Automated Tools

Run when available: `npx semgrep --config auto <target>`, `npm audit`, `pip-audit`, `cargo audit`

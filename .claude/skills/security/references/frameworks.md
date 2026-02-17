# Security Assessment Frameworks

## STRIDE Threat Model

| Threat | Description | Questions to Ask |
|--------|-------------|------------------|
| **S**poofing | Impersonating users/systems | How is identity verified? |
| **T**ampering | Modifying data/code | What integrity controls exist? |
| **R**epudiation | Denying actions | Is there audit logging? |
| **I**nformation Disclosure | Exposing sensitive data | What data could leak? |
| **D**enial of Service | Disrupting availability | What can be exhausted? |
| **E**levation of Privilege | Gaining unauthorized access | Are permissions enforced? |

## OWASP Top 10 (2021)

| # | Vulnerability | Check For |
|---|--------------|-----------|
| A01 | Broken Access Control | Missing auth checks, IDOR, privilege escalation |
| A02 | Cryptographic Failures | Weak algorithms, exposed secrets, missing encryption |
| A03 | Injection | SQL, NoSQL, OS command, LDAP injection |
| A04 | Insecure Design | Missing threat modeling, insecure patterns |
| A05 | Security Misconfiguration | Default credentials, verbose errors, missing headers |
| A06 | Vulnerable Components | Outdated dependencies, known CVEs |
| A07 | Auth Failures | Weak passwords, session issues, credential stuffing |
| A08 | Data Integrity Failures | Insecure deserialization, unsigned updates |
| A09 | Logging Failures | Missing logs, sensitive data in logs |
| A10 | SSRF | Unvalidated URLs, internal network access |

## DREAD Risk Scoring

Use DREAD for severity assessment:

| Factor | Low (1) | Medium (2) | High (3) |
|--------|---------|------------|----------|
| **D**amage | Minor impact | Moderate impact | Severe impact |
| **R**eproducibility | Hard to reproduce | Sometimes reproducible | Always reproducible |
| **E**xploitability | Advanced skills needed | Some skills needed | Easy to exploit |
| **A**ffected Users | Few users | Some users | All users |
| **D**iscoverability | Unlikely to find | Could be found | Obvious |

**Score**: Sum / 5 → Low (1-2), Medium (2-3), High (3+)

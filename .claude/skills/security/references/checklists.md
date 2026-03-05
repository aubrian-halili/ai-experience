# Security Checklists

## API Security Checklist

- [ ] Authentication required on all non-public endpoints
- [ ] Rate limiting configured
- [ ] Input validation and sanitization
- [ ] Response doesn't leak sensitive data
- [ ] CORS configured restrictively
- [ ] API versioning doesn't expose deprecated insecure versions
- [ ] Proper HTTP methods enforced
- [ ] Content-Type validation

## Authentication Checklist

- [ ] Password policy enforced (length, complexity)
- [ ] Passwords hashed with strong algorithm (bcrypt, Argon2)
- [ ] Account lockout after failed attempts
- [ ] Session tokens are random and unpredictable
- [ ] Sessions invalidated on logout
- [ ] Session timeout configured
- [ ] Sensitive actions require re-authentication
- [ ] MFA available for sensitive accounts

## Data Protection Checklist

- [ ] Sensitive data encrypted at rest
- [ ] TLS 1.2+ for data in transit
- [ ] PII minimized and anonymized where possible
- [ ] Data retention policy implemented
- [ ] Backup encryption enabled
- [ ] Access logs for sensitive data
- [ ] Data classification documented

## Dependency Security Checklist

- [ ] Run `npm audit` / `pip-audit` / `cargo audit` — no high/critical vulnerabilities
- [ ] Lock file is committed and up to date
- [ ] No pinned versions with known CVEs
- [ ] No unnecessary dependencies (review `package.json` for unused packages)
- [ ] Dependencies use trusted sources (no typosquatting risk)
- [ ] Major version updates reviewed for breaking changes and security implications

Check for known vulnerabilities:

```bash
npm audit                    # Node.js
pip-audit                    # Python
cargo audit                  # Rust
```

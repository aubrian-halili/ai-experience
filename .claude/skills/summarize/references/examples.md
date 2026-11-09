# Summarize — Worked Examples

All examples use one scenario. Names, numbers, and links are illustrative.

## Scenario

On Tuesday between 09:12 and 10:47 CET, card payments at checkout failed for about 18% of attempts.
The session found that the TLS client certificate our payment service uses to authenticate with the
card payment provider expired at 09:12. Renewal is normally automatic, but the renewal job had been
failing silently since a secrets-path change three weeks earlier. A new certificate was issued and
deployed at 10:47; error rates returned to baseline by 10:52. About 1,400 checkout attempts failed;
roughly 60% of those customers retried successfully within the hour. Invoice and bank-transfer
payments were unaffected.

---

## (a) Non-technical post

Audience: stakeholders, support, product. Under 150 words.

````text
*TL;DR:* Card payments failed for about 1 in 5 customers for 95 minutes on Tuesday morning; the cause is confirmed and fixed.

*What happened*
Between 09:12 and 10:47 CET, some card payments at checkout failed. The cause was an expired security certificate — a digital ID our system uses to prove itself to our card payment provider. It normally renews automatically, but the renewal had stopped working a few weeks earlier without anyone being alerted.

*Impact*
• About 1,400 checkout attempts failed
• Roughly 60% of those customers retried and paid successfully within the hour
• Invoice and bank-transfer payments were not affected

*Next steps*
• Add an alert well before any certificate expires — payments team, by Fri 14 Nov
• Repair the automatic renewal — payments team, by Fri 14 Nov

*Ask*
Support: please point affected customers to retry their card payment.
````

Assumptions: owners given as "payments team" (no names in session); dates taken from the session. Want a technical version, or a shorter one?

---

## (b) Technical post with thread reply

Audience: engineering channel. Main post is short; details go in the thread.

**Main post**

````text
*TL;DR:* Checkout card-payment failures (~18% of attempts, 09:12–10:47 CET Tue) were caused by an expired mTLS client cert for the card provider. Confirmed; new cert deployed, error rate back to baseline.

*Impact*
• ~1,400 failed `POST /checkout/pay` requests; ~60% retried successfully within 1h
• Invoice and bank-transfer flows unaffected

*Next steps*
• Fix cert-renewal job secret path — @dana, Fri 14 Nov
• Add expiry alarm at 14 days and 3 days — @sam, Fri 14 Nov

*Ask*
Review on the alarm PR: <https://github.com/example-org/payments-service/pull/482|payments-service#482>

Details in thread 🧵
````

**Thread reply**

````text
*Root cause (confirmed)*
• Client cert for the card provider expired 09:12 CET; provider rejected the TLS handshake
• Renewal job `cert-rotator` has failed every run since the secrets-path change in <https://github.com/example-org/payments-service/pull/455|#455> — it reads the old path, gets `ResourceNotFoundException`, exits 0, so nothing alerted

*Evidence*
```
09:12:04 ERROR PaymentClient - SSLHandshakeException: Received fatal alert: certificate_expired
```
• Error rate on `/checkout/pay`: 0.4% → 18.2% at 09:12, back to 0.5% at 10:52
• Cert `notAfter` = Tue 09:12:00 CET (checked with `openssl x509 -enddate`)

*Reproduction*
Call the provider sandbox with the expired cert → same `certificate_expired` alert.

*Fix*
• 10:41 issued new cert, stored in Secrets Manager under the new path
• 10:47 rolled service (deploy `sha-3f9c2e1`); errors cleared by 10:52

*Still open*
• `cert-rotator` exits 0 on failure — likely also true for other rotator jobs (not yet checked)
````

Assumptions: technical audience as requested; @dana and @sam taken from the session; one internal hostname removed from the log line. Want a non-technical version, or this as a single post?

---

## Avoid → prefer

| Avoid (jargon) | Prefer (plain language) |
|----------------|-------------------------|
| "mTLS handshake failed due to expired client cert" | "Our system's security certificate — the digital ID that proves us to the payment provider — expired, so the provider refused the connection." |
| "p95 latency regressed 3× after the deploy" | "After Tuesday's update, the slowest pages became about three times slower." |
| "The cron job exits 0 on error, so no alarm fired" | "The automatic renewal was failing, but it reported success, so no one was alerted." |

(This table is guidance for the skill author — Slack messages themselves never contain tables.)

---

## Variants: other session types

TL;DR and findings shape only — the rest follows the structure in `SKILL.md`.

**Research / comparison** (non-technical)

````text
*TL;DR:* We recommend Provider B for card payments: similar cost, and it renews security certificates for us, removing the cause of Tuesday's outage.

*Options compared*
• Provider A (current) — lowest fees; we manage certificates ourselves
• Provider B — ~0.1% higher fees; certificates handled automatically
• Provider C — strong features, but 3–4 months to switch

*Decision needed*
Approve moving to Provider B — product lead, by end of month
````

**In progress** (non-technical, no root cause yet)

````text
*TL;DR:* Still investigating — some card payments are failing (about 1 in 5); we don't have the cause yet.

*What we know*
• Confirmed: failures started at 09:12 CET; only card payments are affected
• Ruled out: today's release (it went out after the failures began)
• Suspected: a problem connecting to our card payment provider — checking now

*Next update*
By 11:00 CET, or sooner if we find the cause.

*Ask*
Support: please point customers to invoice or bank transfer for now.
````

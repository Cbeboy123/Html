## 10.4 - Authentication {#chapter-10-04}

Authentication establishes an identity with stated assurance. Factors derive from something known, possessed, or inherent; multi-factor authentication should use independent factors. Phishing-resistant authenticators protect better than reusable secrets delivered through phishable channels.

Login is a protocol. Rate-limit by several dimensions, avoid user enumeration, protect recovery as strongly as primary authentication, and notify users of consequential changes. Credential stuffing requires breached-password defenses and anomaly controls, not only per-IP limits.

Sessions need high-entropy identifiers, secure transport, rotation after privilege change, bounded idle/absolute lifetime, revocation, and CSRF policy for cookie authentication. Store only necessary session information and bind risky operations to recent authentication when appropriate.

Service authentication uses workload identity, short-lived credentials, and automated rotation. Static shared secrets copied across a fleet create a broad blast radius and weak attribution.

Authentication answers “who or what is this?” It does not answer “may it perform this action?” and it does not prove the request itself is benign.

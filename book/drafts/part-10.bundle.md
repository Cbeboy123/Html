<!-- FILE: book/chapters/part-10/chapter-01-threats-assets-and-trust-boundaries.md -->
## 10.1 - Threats, Assets, and Trust Boundaries {#chapter-10-01}

Security starts with assets and adversaries, not controls. Identify data, money, identity, availability, code execution, reputation, and the administrative capabilities worth protecting. Then map actors, entry points, data flows, stores, and boundaries where trust changes.

Threat modeling asks what can go wrong and what evidence would reveal it. STRIDE is a useful prompt: spoofing, tampering, repudiation, information disclosure, denial of service, and elevation of privilege. It is not a substitute for domain abuse cases such as coupon farming, account recovery fraud, or insider misuse.

~~~mermaid
flowchart LR
    user([Untrusted client]) --> edge[Public edge]
    subgraph trusted[Service trust boundary]
      edge --> app[Application]
      app --> db[(Sensitive data)]
    end
    admin([Privileged operator]) --> app
~~~

*Diagram key: rounded boxes = external actors; rectangles = active components; cylinder = protected data; named subgraph = trust boundary.*

Risk combines likelihood and impact under uncertainty. Prioritize architectural controls—least privilege, isolation, safe workflows, strong identity, and reduced data—before detection-only measures. Revisit the model when data flow, deployment, vendors, or privileges change.

<!-- FILE: book/chapters/part-10/chapter-02-cryptographic-building-blocks.md -->
## 10.2 - Cryptographic Building Blocks {#chapter-10-02}

Cryptography provides narrowly defined properties. A cryptographic hash maps input to a fixed-size digest and should resist practical preimage and collision attacks. A MAC authenticates data using a shared secret. A digital signature authenticates with a private key and verifies with a public key. Encryption provides confidentiality; authenticated encryption also detects tampering.

Never design a new cryptographic protocol. Use maintained libraries and standard constructions. Nonces/IVs have algorithm-specific uniqueness or unpredictability requirements; reuse can catastrophically reveal plaintext or keys. Random tokens need a cryptographically secure generator and sufficient entropy.

Passwords are not encryption keys. Store them with a purpose-built, salted, adaptive password hashing function and tune cost for current hardware. A salt prevents shared precomputation; an optional pepper is a separately protected secret, not a replacement.

Encoding, hashing, encryption, and signing are not interchangeable. Base64 only represents bytes. Hashing does not hide low-entropy values. Encryption without authentication can permit undetected modification.

::: {.interview-tip}
**Interview Tip**

State the property, attacker, and key ownership. Algorithm names without a threat model are cargo culting.
:::

<!-- FILE: book/chapters/part-10/chapter-03-keys-certificates-and-tls-trust.md -->
## 10.3 - Keys, Certificates, and TLS Trust {#chapter-10-03}

A certificate binds a public key to identities and constraints under an issuer’s signature. A relying party builds and validates a chain to a trusted root, checks signatures, time validity, identity match, key usage, and applicable policy. Possessing a certificate file alone does not prove possession of its private key.

Private keys require lifecycle control: generation, inventory, scoped access, storage in a suitable key service or hardware boundary, rotation, revocation response, backup where appropriate, and destruction. Rotation must support overlap so old and new credentials coexist during rollout.

TLS termination defines where plaintext and authenticated peer identity become available. If a proxy terminates client TLS, downstream services must trust identity only through a protected, authenticated hop—not arbitrary forwarded headers. Mutual TLS authenticates both transport endpoints; it does not perform user authorization.

Certificate renewal should be automated and monitored for remaining lifetime and deployment success. Test the whole chain clients actually receive. Pinning and private CAs can reduce or change trust but raise recovery and distribution risk.

<!-- FILE: book/chapters/part-10/chapter-04-authentication.md -->
## 10.4 - Authentication {#chapter-10-04}

Authentication establishes an identity with stated assurance. Factors derive from something known, possessed, or inherent; multi-factor authentication should use independent factors. Phishing-resistant authenticators protect better than reusable secrets delivered through phishable channels.

Login is a protocol. Rate-limit by several dimensions, avoid user enumeration, protect recovery as strongly as primary authentication, and notify users of consequential changes. Credential stuffing requires breached-password defenses and anomaly controls, not only per-IP limits.

Sessions need high-entropy identifiers, secure transport, rotation after privilege change, bounded idle/absolute lifetime, revocation, and CSRF policy for cookie authentication. Store only necessary session information and bind risky operations to recent authentication when appropriate.

Service authentication uses workload identity, short-lived credentials, and automated rotation. Static shared secrets copied across a fleet create a broad blast radius and weak attribution.

Authentication answers “who or what is this?” It does not answer “may it perform this action?” and it does not prove the request itself is benign.

<!-- FILE: book/chapters/part-10/chapter-05-authorization.md -->
## 10.5 - Authorization {#chapter-10-05}

Authorization decides whether a principal may perform an action on a resource in context. Enforce it server-side at every boundary and default deny. Object-level authorization is as important as endpoint access: permission to call `GET /orders/{id}` does not grant every order.

RBAC assigns permissions through roles; ABAC evaluates attributes and context; relationship-based models express graph-like ownership and sharing. Real systems often combine them. Central policy improves consistency, but enforcement points must receive trustworthy identity, resource attributes, and policy version.

Least privilege applies to users, services, operators, database roles, CI systems, and emergency access. Separate duties for irreversible or high-value actions. “Admin” should not become an unbounded escape hatch.

Authorization changes need auditability and revocation semantics. Cached decisions can remain valid after access is removed; define maximum staleness and fail-open/fail-closed behavior. Record who, what, resource, decision, policy, and correlation context without logging secrets.

::: {.gotcha}
**Gotcha**

Hiding a button is user experience, not authorization. The protected service must evaluate the decision.
:::

<!-- FILE: book/chapters/part-10/chapter-06-oauth-2-0-and-openid-connect.md -->
## 10.6 - OAuth 2.0 and OpenID Connect {#chapter-10-06}

OAuth 2.0 delegates authorization: a resource owner permits a client to access a resource server under scopes and policy. OpenID Connect adds an identity layer and an ID token intended for the client. An access token is for the resource server; an ID token is not a general API credential.

For user-facing applications, authorization code flow with PKCE binds the code to the initiating client and avoids exposing credentials in the browser URL. Redirect URIs must be strictly registered. State protects request correlation/CSRF; nonce binds an OIDC authentication response to the client session.

JWT is a token format, not an authentication protocol. A verifier must restrict algorithms, validate signature and issuer, require the correct audience, enforce time claims with bounded skew, and interpret scopes/claims under a local policy. Key rotation and revocation need explicit design. Opaque tokens plus introspection can provide more immediate central control.

Refresh tokens are powerful long-lived credentials. Rotate or sender-constrain them where supported, protect them from untrusted script, and detect reuse. Use short-lived access tokens, narrow audience/scope, and never put secrets or unnecessary personal data into readable token claims.

<!-- FILE: book/chapters/part-10/chapter-07-browser-and-api-security.md -->
## 10.7 - Browser and API Security {#chapter-10-07}

Browsers enforce the same-origin policy, but applications deliberately cross origins through links, forms, CORS, frames, and scripts. CORS tells a browser which origins may read a response; it is not network access control and does not stop non-browser clients.

Prevent XSS with context-aware output encoding, safe templating, reduced dangerous DOM APIs, and a restrictive Content Security Policy as defense in depth. Prevent CSRF for cookie-authenticated state changes with SameSite policy, anti-CSRF tokens, and origin checks. These threats differ: XSS executes in the trusted origin; CSRF induces a victim’s browser to send an authorized request.

APIs must bound size, nesting, rate, and decompressed work; validate syntax and domain invariants; parameterize queries; and avoid unsafe object deserialization. SSRF defenses require allowlisted destinations or controlled egress, URL parsing, DNS/rebinding awareness, and protection of cloud metadata/control endpoints.

Security headers address distinct concerns: transport enforcement, framing, content interpretation, referrer leakage, and browser capabilities. Apply them from a tested baseline and monitor violations without treating headers as the whole security program.

<!-- FILE: book/chapters/part-10/chapter-08-operational-security.md -->
## 10.8 - Operational Security {#chapter-10-08}

Secure software can still be operated insecurely. Build a verifiable chain from source review through isolated CI, pinned dependencies, artifact signing/provenance, controlled deployment, and runtime policy. Protect CI credentials because build systems can modify every shipped component.

Manage vulnerabilities by exploitability, exposure, and business impact—not raw counts. Maintain an inventory and software bill of materials, patch supported components, remove unused packages, and have a process for emergency updates.

Secrets belong in a managed secret system, delivered just in time and scoped to a workload. Do not put them in source, images, logs, command lines, or long-lived environment dumps. Rotation must be rehearsed, including downstream caches and revoked credentials.

Detection needs high-quality audit events, centralized tamper-resistant storage, correlation, and alerts tied to response actions. An incident plan covers containment, credential rotation, evidence preservation, customer/legal obligations, recovery, and lessons without blame.

Backups must be isolated from the credentials and control plane that can destroy production. Test restoration and protect the restore path as a privileged operation.

::: {.interview-tip}
**Interview Tip**

Connect prevention, detection, response, and recovery. “Encrypt everything” does not address compromise of an authorized runtime.
:::

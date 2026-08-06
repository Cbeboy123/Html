## 3.7 - TLS 1.3 and HTTPS {#chapter-03-07}

TLS protects bytes between TLS endpoints. It does not validate the application’s
business logic or keep plaintext secret after either endpoint processes it.

The current TLS 1.3 specification is RFC 9846 (July 2026). It replaces RFC 8446
with a backward-compatible update that tightens and clarifies requirements.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant S as Server
    C->>S: ClientHello + key share
    S-->>C: ServerHello + key share
    S-->>C: Encrypted extensions
    S-->>C: Certificate + proof + Finished
    C->>C: Validate identity and transcript
    C->>S: Finished
    Note over C,S: Protected application data
~~~

*Diagram key: solid arrows are client protocol flights; dashed arrows are server
flights. The self-step is local certificate and transcript validation. This is
the common full TLS 1.3 handshake; optional modes vary.*

The peers perform ephemeral key agreement, derive symmetric traffic keys, and
authenticate the handshake transcript. The server commonly sends a certificate
chain and proves possession of the corresponding private key. The client checks
trust anchors, signatures, validity policy, and that the requested identity
matches the certificate.

Symmetric encryption protects application records efficiently after key
establishment. **Forward secrecy** means later compromise of a long-term
authentication key does not by itself reveal prior sessions that used suitable
ephemeral key agreement.

Session resumption can reduce later handshake work. TLS 1.3 also defines early
data in resumption scenarios, but early data has replay risks and must be limited
to operations safe under the application’s policy.

HTTPS is HTTP over TLS. A reverse proxy terminating TLS becomes a plaintext
access and trust boundary unless another protected connection continues
downstream.

Failures include wrong names, incomplete chains, expired/not-yet-valid
certificates, clock errors, unsupported parameters, and interception policy.
Inspect the actual chain and alert rather than disabling verification.

::: {.interview-tip}
**Interview Tip**

Walk through authentication, key agreement, transcript protection, and symmetric
record encryption. “The certificate encrypts the data” is inaccurate.
:::

# Technical Foundations and Verification Guide {.unnumbered}

This book is self-contained: the reader does not need these sources to understand the material. This section records the primary specifications and official documentation used to verify the most important claims. It also shows where behavior is a standard and where it is product-specific.

The review date for this edition is **August 2026**. Standards and products continue to evolve. The book labels version-sensitive behavior and teaches the mechanism that remains useful when a default changes.

## Internet protocols {.unnumbered}

- **DNS:** IETF RFC 1034 and RFC 1035 define the domain concepts, implementation, resolver, caching, and message behavior used in the DNS chapters.
- **TCP:** IETF RFC 9293 is the current consolidated Transmission Control Protocol specification. Congestion-control algorithms have additional RFCs; the book avoids treating one algorithm as universal.
- **QUIC:** IETF RFC 9000 defines QUIC version 1 transport. It confirms that QUIC supplies secure connection establishment, reliable streams, flow control, congestion control, and connection migration over UDP.
- **TLS 1.3:** IETF RFC 9846, published July 2026, is the current TLS 1.3 specification and replaces RFC 8446. It is a backward-compatible update that tightens and clarifies requirements.
- **HTTP semantics:** IETF RFC 9110 defines resources, representations, methods, status codes, fields, safety, idempotency, and caching-related semantics shared across HTTP versions.
- **HTTP/3:** IETF RFC 9114 maps HTTP semantics onto QUIC and explains independent request streams, HTTP/3 framing, and QPACK.

## Text and language memory models {.unnumbered}

- **Unicode:** The Unicode Standard 17.0 and Unicode Standard Annex #15 define code points, encoding-related concepts, normalization forms, and normalization stability.
- **Java memory model:** Chapter 17 of the Java Language Specification defines synchronization, data races, happens-before, volatile, thread start/join, and allowed observations. The book uses Java only as a clearly labeled example; other languages have their own memory models.

## Databases and streaming {.unnumbered}

- **PostgreSQL 18 documentation:** Chapters on concurrency control, transaction isolation, write-ahead logging, indexes, and query plans validate the labeled PostgreSQL examples. In particular, the documentation distinguishes Read Committed, snapshot-based Repeatable Read, and Serializable Snapshot Isolation.
- **Apache Kafka 4.1 documentation and client API:** The design, producer, consumer, KRaft, replication, transaction protocol, and operations documentation validate the Kafka mechanisms and current defaults. The book keeps end-to-end business effects separate from Kafka transaction scope.

## Security, telemetry, and reliability {.unnumbered}

- **NIST SP 800-63-4:** Current Digital Identity Guidelines for identity proofing, authentication, authenticator management, federation, assurance, security, privacy, and usability.
- **OpenTelemetry specification and documentation:** Defines the telemetry model and signals used to explain traces, metrics, logs, baggage, and profiles.
- **Google Site Reliability Engineering books:** Primary operational material for SLIs, SLOs, error budgets, monitoring, overload, incident response, release engineering, and learning from failure.

## How to use a primary source {.unnumbered}

Specifications define required and allowed behavior. They often do not choose application policy. Product documentation defines behavior for a product and version, but configuration can change the guarantee. A sound engineering conclusion therefore has four parts:

1. the standard or product rule;
2. the exact configuration and version in use;
3. the application invariant or user outcome;
4. a test or observation showing the deployed system behaves as expected.

Do not treat a remembered default as a guarantee. Keep the stable mental model, verify the current boundary, and record the evidence.


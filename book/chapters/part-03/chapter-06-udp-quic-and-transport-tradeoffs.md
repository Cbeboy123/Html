## 3.6 - UDP, QUIC, and Transport Tradeoffs {#chapter-03-06}

**UDP** carries independent datagrams with ports and a checksum. It does not
provide retransmission, ordering, congestion control, or connection state on
behalf of the application. “Unreliable” means those guarantees are absent, not
that datagrams are randomly discarded.

Datagram boundaries are preserved, but payload size is constrained by the path.
Applications should avoid relying on IP fragmentation because loss of one
fragment prevents reassembly of the whole original packet.

UDP suits protocols that need small request/response exchanges, application-
specific recovery, multicast, or tight control over timeliness. The application
still needs congestion-safe behavior when sending substantial traffic.

**QUIC** is a secure transport standardized over UDP. It integrates TLS,
reliability, congestion control, and multiple streams in user space. Loss in one
stream need not block delivery in an unrelated stream, though shared congestion
and connection limits remain.

QUIC connection identity is designed to survive some address changes, supporting
mobility better than a TCP connection tied to endpoint addresses. Exact
migration policy and deployment behavior vary.

HTTP/3 maps HTTP semantics onto QUIC. It does not turn every request into UDP
fire-and-forget traffic; QUIC supplies reliable stream delivery.

::: {.gotcha}
**Gotcha**

“UDP is faster” is not a property independent of requirements. Once an
application adds reliability, ordering, encryption, pacing, and recovery, it
has built a transport protocol and must operate it safely.
:::

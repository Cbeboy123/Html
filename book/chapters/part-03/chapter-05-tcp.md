## 3.5 - TCP {#chapter-03-05}

TCP presents applications with a reliable ordered **byte stream**. It does not
preserve application message boundaries; the application must frame messages.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant S as Server
    C->>S: SYN, client initial sequence
    S-->>C: SYN + ACK, server initial sequence
    C->>S: ACK
    Note over C,S: Connection established; application bytes may flow
~~~

*Diagram key: solid arrows are TCP handshake segments; dashed arrow is the
server acknowledgment flight. Sequence values are selected per connection.*

Sequence numbers identify byte positions. Acknowledgments report received
progress; retransmission repairs suspected loss. Checksums detect corruption
within their defined scope. TCP orders delivered bytes even if IP packets arrive
out of order.

**Flow control** prevents a sender from overrunning receiver buffer capacity.
**Congestion control** adapts sending to inferred network capacity and
congestion. These are different constraints. Algorithms and initial settings
are implementation- and version-specific.

A connection is identified by endpoint addressing and ports in its network
context. Connection establishment consumes state at both ends and can fail due
to routing, filtering, listen backlog pressure, ephemeral-port exhaustion, or
server resource limits.

Close is bidirectional: each direction can finish separately. A reset aborts the
connection. Half-open and idle connections require application deadlines and
health policy; TCP keepalive defaults vary and should not be guessed.

The Nagle algorithm, delayed acknowledgments, buffering, and small writes can
interact, but do not memorize folklore as universal tuning advice. Capture
segments and measure the application’s write pattern.

::: {.interview-tip}
**Interview Tip**

Say what TCP guarantees—and what it does not: no message boundaries, no
application deadline, no guarantee the peer committed a received request.
:::

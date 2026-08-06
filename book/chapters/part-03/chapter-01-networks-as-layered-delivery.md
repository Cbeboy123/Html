## 3.1 - Networks as Layered Delivery {#chapter-03-01}

A browser sends one HTTP request, yet a packet capture shows frames, IP packets,
transport headers, encrypted records, acknowledgments, and retransmissions.
Layering lets each mechanism solve a bounded problem.

**Encapsulation** wraps data from a higher layer with information needed by a
lower layer. A common Internet path carries application messages inside a
transport protocol, inside IP packets, inside link-layer frames. The OSI model
is a seven-layer teaching model; the TCP/IP suite is the deployed family. Their
layer boundaries do not map perfectly.

~~~mermaid
flowchart TB
    app[Application message] --> transport[Transport segment or datagram]
    transport --> ip[IP packet]
    ip --> link[Link-layer frame]
    link --> medium([Physical or virtual link])
    medium -.-> peer[Peer decapsulates in reverse]
~~~

*Diagram key: rectangles are protocol-layer representations; rounded box is the
link outside the host; solid arrows encapsulate; dashed arrow shows independent
decapsulation by the peer.*

Each layer has a different scope. Ethernet-style delivery is local to a link;
IP routes across interconnected networks; TCP can provide a reliable ordered
byte stream between endpoints; TLS protects application bytes between its
termination points; HTTP defines request/response semantics.

Packet size is bounded along a path. If a packet is too large, a protocol may
fragment it, discover a usable size, or fail. Exact maximums and discovery
behavior depend on the link, IP version, tunneling, and configuration. “Works
for small requests” can therefore coexist with “large responses stall.”

Layering is not perfect isolation: congestion affects application latency, TLS
termination changes the trust boundary, and proxies may interpret HTTP.
Troubleshooting follows the boundary where the guarantee stops.

::: {.interview-tip}
**Interview Tip**

Name the unit and scope: frame on one link, packet across IP, byte stream or
datagram at transport, message at the application. Avoid treating every unit as
a “packet.”
:::

<!-- FILE: book/chapters/part-03/chapter-01-networks-as-layered-delivery.md -->
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

<!-- FILE: book/chapters/part-03/chapter-02-local-networks.md -->
## 3.2 - Local Networks {#chapter-03-02}

Before an IP packet reaches a router, a host must deliver a frame to the next
hop on its local link.

A **switch** forwards link-layer frames using learned addresses. A router
forwards IP packets between networks. A host compares the destination with its
local routes: a local destination is reached directly; a remote destination is
sent to a gateway.

For IPv4, **ARP** maps a local IPv4 address to a link-layer address. IPv6 uses
Neighbor Discovery, carried through ICMPv6, for related functions. These
mechanisms are local-link protocols and are not general Internet directories.

**DHCP** supplies configuration such as an address, prefix, gateway, and DNS
resolver information. Exact options and lease behavior vary. DHCP does not
prove that the assigned route or DNS service is reachable.

Local-network failures include duplicate addresses, stale neighbor entries,
wrong VLAN membership, incorrect prefixes, and asymmetric security policy.
Packet capture should be taken at the boundary relevant to the hypothesis: an
application capture cannot show a frame dropped before reaching the host.

Broadcast and multicast traffic have bounded domains. Network segmentation
limits failure and trust scope, but adds routing and policy boundaries.

::: {.gotcha}
**Gotcha**

ARP does not find a remote server’s hardware address. The host resolves the
link-layer address of the next hop—often its gateway.
:::

::: {.interview-tip}
**Interview Tip**

Walk through the routing decision before ARP/Neighbor Discovery. That prevents
the common error of resolving the final remote host on the local link.
:::

<!-- FILE: book/chapters/part-03/chapter-03-ip-addressing-and-routing.md -->
## 3.3 - IP Addressing and Routing {#chapter-03-03}

An IP address identifies an interface in a routing context, not a permanent
machine identity. Hosts can have several interfaces and addresses; addresses
can move or change.

**CIDR** writes an address prefix with its prefix length. The prefix identifies
the shared leading bits used for route aggregation and subnet reasoning. A
router commonly uses **longest-prefix match**: among matching routes, choose the
most specific prefix, then apply product-specific policy among equivalent
candidates.

~~~mermaid
flowchart LR
    host([Source host]) --> r1[Router: longest-prefix lookup]
    r1 -->|selected next hop| r2[Next router]
    r2 --> destination([Destination network])
    r1 --x|no route or policy deny| drop{Drop}
~~~

*Diagram key: rounded boxes are endpoint networks; rectangles route; diamond is
a terminal condition; solid arrows forward; cross-ended arrow is a failed path.*

IPv4 address scarcity led to widespread **NAT**, which rewrites addressing
information at a boundary. NAT is not a firewall by definition, though devices
often combine both. IPv6 provides a much larger address space and removes the
technical need for address-conservation NAT, but security policy remains
necessary.

**ICMP** carries control and diagnostic messages, including error reporting.
Blocking all ICMP can break diagnostics and mechanisms such as path size
discovery. Filtering should distinguish message types and threat model.

Routing can be asymmetric: forward and return paths need not match. Stateful
firewalls, NAT, and troubleshooting assumptions must account for this.

::: {.interview-tip}
**Interview Tip**

Given a destination, apply the routing table’s longest matching prefix and name
the next hop. Do not decide “same subnet” from visual similarity of addresses.
:::

<!-- FILE: book/chapters/part-03/chapter-04-dns.md -->
## 3.4 - DNS {#chapter-03-04}

Typing a host name does not usually cause the browser to contact the
authoritative server directly. Resolution crosses caches and delegated
authority.

~~~mermaid
sequenceDiagram
    participant App as Application
    participant Stub as Stub resolver
    participant Rec as Recursive resolver
    participant Root as Root server
    participant TLD as TLD server
    participant Auth as Authoritative server
    App->>Stub: Resolve name
    Stub->>Rec: Query
    Rec->>Root: Ask for name
    Root-->>Rec: Referral to TLD
    Rec->>TLD: Ask for name
    TLD-->>Rec: Referral to authority
    Rec->>Auth: Ask for record
    Auth-->>Rec: Answer
    Rec-->>Stub: Cached answer
    Stub-->>App: Addresses or error
~~~

*Diagram key: solid arrows are DNS queries; dashed arrows are answers or
referrals. A recursive resolver may answer from cache and skip later flights.*

The **stub resolver** is the local client-facing resolver. A **recursive
resolver** performs work on the client’s behalf. **Authoritative servers**
publish data for zones. Delegation connects the hierarchy; it is not a search
through one central database.

Records have TTLs that guide caching. TTL expiration permits refresh but does
not make change globally instantaneous: caches may have started at different
times, and application/OS caches add layers. Negative answers can also be
cached under DNS rules.

Common record purposes include addresses, aliases, mail routing, name-server
delegation, and arbitrary text. An alias chain still ends in data usable by the
client. DNS can return several addresses; selection and retry are client
behavior, not a DNS availability guarantee.

Failures include SERVFAIL from resolver/authority trouble, NXDOMAIN for a
nonexistent name, timeouts, broken delegation, stale caches, DNSSEC validation
failure, and split-horizon views. Diagnose by naming the resolver queried,
observed response code, authority path, and cache state.

::: {.interview-tip}
**Interview Tip**

Distinguish recursion from iteration, then mention positive and negative
caching. “DNS maps names to IPs” misses delegation, record types, and failure.
:::

<!-- FILE: book/chapters/part-03/chapter-05-tcp.md -->
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

<!-- FILE: book/chapters/part-03/chapter-06-udp-quic-and-transport-tradeoffs.md -->
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

<!-- FILE: book/chapters/part-03/chapter-07-tls-1-3-and-https.md -->
## 3.7 - TLS 1.3 and HTTPS {#chapter-03-07}

TLS protects bytes between TLS endpoints. It does not validate the application’s
business logic or keep plaintext secret after either endpoint processes it.

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

<!-- FILE: book/chapters/part-03/chapter-08-http.md -->
## 3.8 - HTTP {#chapter-03-08}

HTTP defines request and response semantics above a transport. A method, target,
headers, and optional content form a request; a status, headers, and optional
content form a response.

**Safe** methods are intended not to request state change. **Idempotent** methods
are intended to have the same requested effect when repeated. These semantic
properties guide retries but cannot prevent a buggy handler or incidental
logging.

HTTP/1.1 commonly reuses connections but serializes message syntax on each
connection. HTTP/2 multiplexes streams over one connection and compresses
headers; TCP loss still affects the connection’s byte stream. HTTP/3 maps
streams onto QUIC, reducing transport-level cross-stream blocking.

Caching requires an explicit model. Freshness metadata can permit reuse without
contacting the origin. A validator such as an ETag enables a conditional request
and a “not modified” response. `Vary` makes selected request headers part of the
cache key. Shared and private caches have different authorization and privacy
concerns.

Cookies are name/value state selected by domain/path and policy attributes, then
sent with matching requests. Secure, HttpOnly, and SameSite attributes address
different threats; none replaces server-side authorization.

Status codes describe the HTTP result, not necessarily the complete business
outcome. A timeout after sending a request creates an ambiguous result: the
server may have committed it even though no response arrived.

::: {.interview-tip}
**Interview Tip**

Tie retries to method semantics, idempotency controls, and ambiguous outcomes.
Do not say “GET always succeeds” or “POST can never be retried.”
:::

<!-- FILE: book/chapters/part-03/chapter-09-network-intermediaries.md -->
## 3.9 - Network Intermediaries {#chapter-03-09}

Requests often cross several intermediaries, each adding a routing, policy, or
trust boundary.

A **forward proxy** acts on behalf of a client. A **reverse proxy** accepts
traffic on behalf of servers. A layer-4 load balancer routes using transport
information; a layer-7 load balancer can inspect application protocol fields.
Products may combine these roles.

~~~mermaid
flowchart LR
    client([Client]) --> edge[CDN or edge proxy]
    edge --> lb[Load balancer]
    lb --> app1[Application instance A]
    lb --> app2[Application instance B]
    edge -.-> cache[(Edge cache)]
    lb --x|health or policy reject| reject{Reject}
~~~

*Diagram key: rounded box is external client; rectangles process or route;
cylinder stores cached representations; solid arrows are request paths; dashed
arrow is cache interaction; cross-ended arrow is rejection.*

Load balancing algorithms distribute new work using information available at
their layer. Least-connections, hashing, and round-robin-like policies have
different behavior under uneven request cost, long-lived connections, and
failure. Health checks can only test their configured condition.

A **CDN** serves content from edge locations and can terminate TLS, cache
representations, filter traffic, and route to origins. Cache invalidation and
personalized content require precise keys and policy.

A firewall enforces traffic policy. A VPN creates a protected logical network
path; it does not make endpoints trustworthy. NAT rewrites addressing. These
functions are often bundled, which should not blur their separate guarantees.

Intermediaries affect client identity and scheme information. Forwarded headers
must be accepted only from trusted hops; otherwise clients can forge them.
Timeouts should form a decreasing budget toward downstream work so outer layers
retain time to handle failure.

::: {.interview-tip}
**Interview Tip**

For each hop, state what it terminates, what it can observe, which identity it
trusts, and how its timeout relates to the caller’s deadline.
:::

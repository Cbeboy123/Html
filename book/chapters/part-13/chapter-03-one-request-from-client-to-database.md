## 13.3 - One Request from Client to Database {#chapter-13-03}

When a request is slow, avoid saying “the network is slow.” Follow the request through boundaries. Each boundary has its own unit, guarantee, queue, timeout, and evidence.

### Step 1: name resolution

The client asks a configured resolver for records that can reach the service. The resolver may answer from cache or follow DNS delegation to authoritative servers. A DNS answer can contain several addresses. It does not guarantee that an address is reachable or healthy.

Useful evidence includes the resolver that was asked, response code, returned records, TTL, and elapsed time. `NXDOMAIN` means the queried name does not exist in DNS. `SERVFAIL` means the resolver could not produce a valid answer. A timeout is different from both.

### Step 2: routing and local delivery

The host chooses a route for the destination. On the local link it resolves the address of the next hop, often the gateway. Routers then forward IP packets. NAT, VPNs, firewalls, and tunnels may rewrite, wrap, or reject traffic.

The forward and return paths can differ. A successful ping does not prove that the application port, TLS identity, or HTTP route works. ICMP, TCP, UDP, and application traffic may have different policy.

### Step 3: transport

For TCP, the peers establish connection state and exchange an ordered byte stream. TCP repairs detected loss and applies flow and congestion control. It does not preserve application message boundaries and does not provide an application deadline.

QUIC runs over UDP but supplies secure connection state, reliable streams, flow control, congestion control, and migration features. HTTP/3 maps HTTP semantics onto QUIC streams. One stream's lost data need not stop delivery on unrelated streams, although all streams still share the connection's network path and congestion control.

::: {.fact}
**Worth Knowing - HTTP meaning is separate from its wire version**

GET, POST, status codes, fields, caching, and resource semantics are shared HTTP ideas. HTTP/1.1, HTTP/2, and HTTP/3 carry those ideas differently. HTTP/3 is not “UDP without reliability”; QUIC supplies reliable per-stream delivery.
:::

### Step 4: TLS

TLS 1.3 authenticates the server in the common web case, establishes traffic keys, protects the handshake transcript, and then protects application records. The current TLS 1.3 specification is RFC 9846, published in July 2026 as a backward-compatible update to RFC 8446.

Certificate validation includes the requested identity, chain to a trusted root, signatures, time validity, and policy. The certificate does not encrypt all application data by itself. The handshake establishes symmetric keys that protect records efficiently.

TLS ends wherever it is terminated. If a load balancer terminates TLS, it can see plaintext. A second TLS connection may protect the next hop, but it is a new security context.

### Step 5: HTTP and intermediaries

The request can cross a CDN, web application firewall, reverse proxy, and load balancer before reaching application code. At each hop ask:

- Does this hop terminate a connection?
- Which identity and forwarded fields does it trust?
- Can it cache, retry, compress, or reject the request?
- What timeout does it apply?
- Which request identifier does it record?

Forwarded identity fields must be accepted only from trusted intermediaries. Otherwise a client can send a forged header that looks internal.

### Step 6: application admission and work

The application may wait before it runs: accept queue, request queue, thread pool, semaphore, or rate limiter. Then it authenticates, authorizes, validates, and applies domain rules. It may call a cache, database, broker, or another service.

Database time is a pipeline of its own: connection-pool wait, network, parse/bind, planning, locks, execution, storage, row transfer, and client consumption. “The query took 500 ms” is ambiguous until the measured boundary is named.

### Step 7: response and ambiguous failure

The response crosses logical boundaries in reverse, but the network route may differ. If the connection fails after the server commits a mutation, the client sees a timeout even though the effect happened. Transport delivery cannot prove business commit to a caller that did not receive the application response.

### A diagnostic decision table

| Last confirmed evidence | Likely boundary to inspect next |
|---|---|
| No DNS answer | Resolver, delegation, DNSSEC, network policy |
| Address returned, no connection | Route, firewall, listener, backlog, port exhaustion |
| Connected, TLS alert | Identity, chain, clock, version, cipher/policy |
| TLS complete, no HTTP response | Proxy policy, application admission, overload |
| Fast edge, slow application span | Application queue, CPU, dependency spans |
| Fast server response, slow user readiness | Transfer, browser/client CPU, rendering, client retries |

One trace is useful, but it is not proof of fleet health. Compare a failing request with a healthy request of the same operation, region, tenant, and version. Then use distributions and saturation signals to see whether the cause is local or systemic.

::: {.interview-tip}
**Staff-Level Answer**

Walk the normal path once. Then choose two plausible failure branches and say which observation distinguishes them. A long list of protocols without decision evidence is not diagnosis.
:::


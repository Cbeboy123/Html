<!-- FILE: book/chapters/part-04/chapter-01-before-the-network.md -->
## 4.1 - Before the Network {#chapter-04-01}

The journey starts before a packet exists. The browser interprets input, applies
policy, and checks state that may make the network unnecessary.

The input may be parsed as a URL or transformed into a search request. A URL
contains a scheme, authority, path, query, and optional fragment under its
syntax. The fragment is normally interpreted by the client and is not sent in
the HTTP request.

The browser applies security policies such as blocked schemes, mixed-content
rules, and upgrade mechanisms. It may consult:

- an HTTP cache for a reusable representation;
- a service worker capable of handling the request;
- a pre-existing connection or connection pool;
- cached DNS information;
- proxy configuration and enterprise policy;
- credentials, cookies, and client certificates applicable to the destination.

Browser extensions can modify or block navigation. Exact ordering and cache
layers are browser-specific, so diagnosis must use that browser’s developer
tools and policy state.

If a fresh cached response satisfies the request, DNS and transport work may not
occur. A stale response may be revalidated conditionally. A service worker can
respond from its own storage, go to the network, or combine both.

::: {.gotcha}
**Gotcha**

“Clear the browser cache” is not a complete experiment. DNS caches, service
workers, proxies, operating-system state, and existing connections are separate
layers.
:::

::: {.interview-tip}
**Interview Tip**

Begin with URL parsing and local policy, not DNS. State which local checks could
short-circuit the remaining journey.
:::

<!-- FILE: book/chapters/part-04/chapter-02-finding-and-reaching-the-destination.md -->
## 4.2 - Finding and Reaching the Destination {#chapter-04-02}

If the browser needs the network, it resolves the host name and selects a
reachable address. Address-family preference, cached information, and connection
racing are client implementation choices.

~~~mermaid
sequenceDiagram
    participant B as Browser
    participant R as Resolver
    participant E as Edge endpoint
    B->>R: Resolve host name
    R-->>B: Addresses or error
    B->>E: TCP SYN or QUIC initial flight
    E-->>B: Transport response
    B->>E: TLS 1.3 handshake flights
    E-->>B: Authenticated handshake completion
    B->>E: Protected HTTP request
~~~

*Diagram key: solid arrows are client queries/protocol flights; dashed arrows
are resolver or endpoint responses. “Edge endpoint” may be a CDN, proxy, or
origin reached by the selected address.*

The host routes the first packet toward a next hop, resolving its local
link-layer address if needed. Routers forward the IP packet according to their
tables. NAT or firewalls may rewrite or filter it.

For HTTP over TLS/TCP, the TCP handshake establishes transport state, then TLS
authenticates the endpoint and derives keys. HTTP/3 uses QUIC, which integrates
transport and TLS handshake work. Resumption can reduce some work; it does not
remove identity and replay-policy concerns.

Failures can occur before the application sees a request: name resolution,
route selection, packet filtering, path-size problems, transport timeout,
certificate validation, protocol negotiation, or edge overload. Evidence from
only the application log cannot distinguish these.

::: {.interview-tip}
**Interview Tip**

Name the protocol branch: TCP+TLS for common HTTPS over HTTP/1.1 or HTTP/2;
QUIC+TLS integration for HTTP/3. Do not describe both as simultaneous mandatory
handshakes.
:::

<!-- FILE: book/chapters/part-04/chapter-03-across-the-service.md -->
## 4.3 - Across the Service {#chapter-04-03}

The first server reached is often not the application. An edge proxy may
terminate TLS, enforce policy, serve a cache hit, or forward the request.

~~~mermaid
flowchart LR
    browser([Browser]) --> edge[CDN or edge proxy]
    edge --> waf[Policy and routing]
    waf --> lb[Load balancer]
    lb --> app[Application]
    app --> cache[(Application cache)]
    app --> db[(Database)]
    app -.-> downstream[Downstream service]
    edge -.-> edgecache[(Edge cache)]
~~~

*Diagram key: rounded box is the external browser; rectangles actively process
the request; cylinders store data; solid arrows are direct calls; dashed arrows
are optional/deferred dependency or cache paths.*

Every termination point creates a new connection and observation boundary. The
edge may speak a different HTTP version downstream. A load balancer selects an
eligible instance, but its health check proves only the tested condition.

The application authenticates the caller, authorizes the operation, validates
input, and performs domain logic. It may read a cache, execute a database
transaction, publish a message, or call dependencies. Each step has its own
timeout, pool, queue, and failure semantics.

A database “response” can include time waiting for a connection, parsing,
locking, execution, storage I/O, and network transfer. A cache hit avoids some
of that work but introduces staleness and invalidation policy.

Retries at several layers can multiply one user request. Use an end-to-end
request identifier and trace context, but do not trust caller-supplied identity
headers unless a trusted boundary overwrites or validates them.

::: {.interview-tip}
**Interview Tip**

For each hop, state the termination, timeout, retry ownership, and evidence.
That turns a component list into an end-to-end mechanism.
:::

<!-- FILE: book/chapters/part-04/chapter-04-returning-and-rendering.md -->
## 4.4 - Returning and Rendering {#chapter-04-04}

The response retraces logical boundaries, not necessarily the same physical
network path. Each intermediary may buffer, compress, cache, transform allowed
metadata, or terminate a downstream connection.

The browser parses the status and headers before consuming content. Caching
rules determine whether the representation can be stored. Content encoding
such as compression is reversed before the media type is interpreted.

For HTML, the browser incrementally constructs a document model, discovers
subresources, and applies CSS. Scripts can block or modify parsing depending on
their attributes and execution. Layout computes geometry; painting produces
drawing operations; compositing combines layers. Exact pipelines are
browser-specific.

Subresources trigger their own URL journeys, though connection reuse,
multiplexing, DNS state, caches, preloading, and priorities can reduce repeated
work. A visually complete page is therefore not the same milestone as receiving
the first response byte.

Useful user-facing milestones include:

- navigation start;
- response headers or first byte;
- meaningful content rendered;
- main-thread responsiveness;
- completion of critical subresources;
- application-specific readiness.

Client CPU, memory pressure, long script tasks, fonts, and layout changes can
dominate after a fast backend response. Server traces alone cannot explain that
time.

::: {.gotcha}
**Gotcha**

“Page load time” is ambiguous. Define the observed milestone and the clock used
before comparing measurements.
:::

<!-- FILE: book/chapters/part-04/chapter-05-a-latency-and-failure-ledger.md -->
## 4.5 - A Latency and Failure Ledger {#chapter-04-05}

A latency ledger accounts for elapsed time at boundaries without inventing a
universal budget. Measure timestamps from the same clock where possible and use
trace relationships—not wall-clock subtraction across unsynchronized hosts.

~~~mermaid
flowchart TB
    start([Navigation start]) --> local[Local policy and cache]
    local --> dns[Name resolution]
    dns --> transport[Transport and TLS]
    transport --> edge[Edge and load balancing]
    edge --> app[Application and queues]
    app --> data[Cache, database, dependencies]
    data --> response[Response transfer]
    response --> render[Parse, layout, paint, scripts]
    render --> ready([Defined user-ready milestone])
~~~

*Diagram key: rounded boxes are user-visible milestones; rectangles are measured
stages; solid arrows show elapsed-time accumulation in explanation order.*

| Stage | Evidence | Representative failures |
|---|---|---|
| Local/browser | Navigation timing, cache/service-worker inspection | Policy block, stale client state |
| DNS | Resolver timing and response code | Timeout, NXDOMAIN, SERVFAIL, broken delegation |
| Transport/TLS | Packet/connection timing, TLS alerts | Drop, reset, certificate failure |
| Edge | Edge request ID and timing | Cache error, policy reject, origin connect failure |
| Application | Trace spans, queue/pool metrics | Saturation, timeout, exception |
| Data/dependency | Query/consumer/client spans and server metrics | Lock wait, pool exhaustion, downstream failure |
| Rendering | Browser performance profile | Long task, layout work, resource blocking |

Queueing can occur before every active stage. Averages hide a minority of severe
waits, so inspect distributions and correlate them with saturation. Retries
should appear as child attempts under one logical operation; otherwise they
look like independent traffic.

Failure diagnosis proceeds outside-in until evidence crosses the failing
boundary. If DNS never returns, application logs are irrelevant. If the server
responds quickly but the main thread is blocked, database tuning is irrelevant.

::: {.interview-tip}
**Interview Tip**

Walk the ledger in order, but branch when evidence does. State the next
measurement that would distinguish two hypotheses rather than listing every
possible failure.
:::

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

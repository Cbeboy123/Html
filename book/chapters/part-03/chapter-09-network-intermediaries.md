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

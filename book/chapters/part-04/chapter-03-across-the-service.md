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

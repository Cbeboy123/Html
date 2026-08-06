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

## 13.7 - Consensus, Fencing, and Cross-System Workflows {#chapter-13-07}

Distributed systems become difficult because a missing response has several possible causes. The peer may be dead, slow, paused, unreachable, or working normally while the reply is lost. A timeout gives permission to stop waiting; it does not reveal which cause occurred.

### Failure detection is suspicion

A failure detector uses missing heartbeats or responses to suspect a node. Short timeouts recover faster but create more false suspicions. Long timeouts reduce false suspicions but extend outages. Adaptive detectors can use observed delay, but still cannot produce certainty during a network partition.

This is why “promote a new leader after a timeout” is incomplete. The system must prevent the old leader from continuing to act.

### Consensus orders authority

In a leader-based consensus protocol, a quorum elects a leader for a numbered term or epoch. The leader proposes ordered log entries. Entries become committed only under the protocol's quorum rules. Followers learn and apply the committed order.

Consensus provides a foundation for one ordered replicated state machine under a stated failure model. It does not make a minority partition writable, remove disk failures, or make clients retry-safe.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant L as Leader, term 12
    participant F1 as Follower A
    participant F2 as Follower B
    C->>L: Propose change X
    L->>F1: Append X at index 90
    L->>F2: Append X at index 90
    F1-->>L: Persisted
    F2-->>L: Persisted
    L->>L: Quorum reached; commit X
    L-->>C: Success
~~~

*Diagram key: solid arrows are proposals and replication; dashed arrows are acknowledgments; the self-step is the commit decision.*

If the client misses the final success, it still has an ambiguous outcome. Consensus made the internal decision safe; the client needs an operation ID or status read.

### Leases need fencing

Suppose worker A holds a 30-second lease. A pauses for 45 seconds. The lease expires, so worker B obtains a new lease. A resumes and still believes it is the owner. Now both can act.

A **fencing token** prevents this. Every new owner receives a larger token: 41, then 42. The protected storage or device records the latest token and rejects operations carrying an older value.

~~~mermaid
flowchart LR
    a[Old owner: token 41] --x store[(Resource accepts 42+)]
    b[New owner: token 42] --> store
~~~

*Diagram key: rectangles are workers; cylinder is protected state; cross-ended arrow is a rejected stale action.*

A lease without fencing is only a belief held by the lease service. Safety exists when the final resource enforces current authority.

::: {.fact}
**Worth Knowing - Clocks do not fix authority**

Even well-synchronized wall clocks have uncertainty and can jump. Use a monotonic clock for local elapsed time. Use protocol terms, versions, and fencing tokens for distributed authority.
:::

### Cross-system work cannot pretend to be one local transaction

An application often needs to update a database and publish an event. If it writes the database first and crashes before publishing, state changes without an event. If it publishes first and the database write fails, consumers see an event for state that does not exist.

The **transactional outbox** solves this when both domain state and an outbox row share one database transaction:

~~~mermaid
flowchart LR
    api[Business transaction] --> db[(Domain state + outbox row)]
    db ==> relay[Relay or change capture]
    relay -.-> log{{Event log}}
    log -.-> consumer[Idempotent consumer]
~~~

*Diagram key: cylinder is durable state; thick arrow is a sustained capture stream; hexagon is a retained log; dashed arrows are asynchronous delivery.*

The relay can publish more than once if it crashes after publish and before marking progress. Consumers still need a stable event ID and idempotent effect.

### Sagas are durable workflows, not rollback magic

A saga coordinates local transactions across services. After one step commits, a later failure triggers a compensating business action where possible. A refund does not erase that a charge happened. A cancellation email cannot make a previous email unseen.

A robust saga stores:

- workflow ID and current state;
- completed step IDs and results;
- retry and deadline policy;
- compensation status;
- manual-review state;
- audit and correlation data.

Each step and compensation must be idempotent. The coordinator must resume after restart. Operators need a way to inspect and repair stuck workflows.

### Distributed decision checklist

1. Which node or datastore is authoritative for each fact?
2. Which failure model is covered: process, machine, zone, region, or operator error?
3. Which quorum intersects competing decisions?
4. How are stale leaders fenced at the final resource?
5. What does the client do after an ambiguous result?
6. Which state is atomic, and which state only converges?
7. How are duplicates, gaps, and compensation detected?
8. Which restore or failover exercise proves the recovery claim?

::: {.interview-tip}
**Staff-Level Answer**

Separate internal consensus safety from client-visible idempotency and cross-system convergence. They solve different failure windows.
:::


<!-- FILE: book/chapters/part-09/chapter-01-why-distribution-changes-the-rules.md -->
## 9.1 - Why Distribution Changes the Rules {#chapter-09-01}

Inside one process, memory is shared and failure is often obvious. Across machines, messages take time, can be lost or duplicated, and reveal no perfect distinction between a slow peer, a broken link, and a failed peer. Nodes restart with different knowledge; clocks disagree; operators change the system while it runs.

The central fact is **partial failure**: one component can fail while others continue. A caller that times out does not know whether the request was never received, is still executing, or committed and lost its response. Every remote mutation therefore needs an ambiguity strategy: idempotency, status lookup, deduplication, or reconciliation.

Distribution is justified by availability, scale, geography, isolation, or organizational boundaries—not fashion. It introduces serialization, compatibility windows, network policy, independent queues, and operational coordination.

::: {.key-terms}
**Key Terms**

Safety means nothing bad happens (for example, two primaries do not both commit conflicting ownership). Liveness means useful progress eventually occurs. A design must state assumptions—failure type, timing, quorum, and storage durability—before claiming either.
:::

<!-- FILE: book/chapters/part-09/chapter-02-scalability-availability-reliability-and-fault-toleran.md -->
## 9.2 - Scalability, Availability, Reliability, and Fault Tolerance {#chapter-09-02}

These properties are related but distinct. **Scalability** is the ability to handle growth by adding or changing resources without unacceptable degradation. **Availability** is the proportion or probability of successful service at defined boundaries. **Reliability** is continued correct behavior over time. **Fault tolerance** is preserving a specified service despite specified faults.

Define the service first. A read-only status page may be available while checkout is unavailable. A response can be fast and wrong. “Five nines” is meaningless without population, window, exclusions, and success criteria.

Vertical scaling increases one node’s capacity; horizontal scaling distributes work. Stateless request handling eases horizontal scaling, but state still exists in databases, caches, sessions, queues, and rate limits. Amdahl’s law reminds us that an unscaled serial fraction bounds total speedup.

Redundancy improves fault tolerance only when replicas do not share the failing dependency. It also adds modes: stale data, split brain, failover, and repair. Use error budgets to balance reliability work with change, and test fault assumptions through controlled exercises.

::: {.interview-tip}
**Interview Tip**

Give a metric and failure scope for each “-ility.” Do not use availability and reliability as synonyms.
:::

<!-- FILE: book/chapters/part-09/chapter-03-replication-and-quorums.md -->
## 9.3 - Replication and Quorums {#chapter-09-03}

Replication keeps copies for availability, locality, read scale, or durability. Synchronous replication waits for defined replicas before acknowledgment; asynchronous replication reduces foreground latency but permits lag and possible acknowledged-data loss after failover.

A quorum chooses intersecting read and write sets. In a simplified system with `N` replicas, write quorum `W`, and read quorum `R`, `W + R > N` creates overlap. That arithmetic alone does not guarantee linearizability: versions, leader rules, conflict resolution, failure detection, and sloppy placement still matter.

~~~mermaid
flowchart TB
    client([Client]) --> coordinator[Coordinator]
    coordinator ==> a[(Replica A)]
    coordinator ==> b[(Replica B)]
    coordinator ==> c[(Replica C)]
    a --> q{Enough valid acknowledgments?}
    b --> q
    c --> q
    q -->|yes| ok([Complete])
    q --x|no before deadline| fail{Unavailable or ambiguous}
~~~

*Diagram key: rounded boxes = external outcomes; rectangle = coordinator; cylinders = replicas; thick arrows = replication; diamond = quorum condition; cross-ended arrow = failed completion.*

Repair is part of replication: followers catch up, divergent versions reconcile, and checksums or anti-entropy find missed data. A replica count without placement and repair objectives is not an availability design.

<!-- FILE: book/chapters/part-09/chapter-04-failure-detection-election-and-consensus.md -->
## 9.4 - Failure Detection, Election, and Consensus {#chapter-09-04}

Failure detectors infer from missing evidence. A timeout too short causes false suspicion; too long delays recovery. Networks can partition so both sides remain alive. Election must therefore establish exclusive authority, not merely choose the fastest volunteer.

**Consensus** lets nodes agree on a sequence/value despite failures within a model. Leader-based protocols such as Raft replicate a log: a majority elects a leader; entries become committed under protocol rules; followers apply the committed order. Paxos and Raft differ in exposition and mechanics, but neither makes an unavailable majority writable.

~~~mermaid
sequenceDiagram
    participant L as Leader, term 8
    participant F1 as Follower 1
    participant F2 as Follower 2
    L->>F1: Append entry at index 42
    L->>F2: Append entry at index 42
    F1-->>L: Persisted
    F2-->>L: Persisted
    L->>L: Majority reached; commit
~~~

*Diagram key: solid arrows = replication; dashed arrows = acknowledgments; self-step = commit decision under the protocol.*

Use **fencing tokens**—monotonically increasing authority numbers—when an old leader might resume. The protected resource rejects stale tokens, turning uncertain liveness into enforceable safety.

::: {.gotcha}
**Gotcha**

A distributed lock lease without fencing can expire while the old holder is paused; both old and new holders may then act.
:::

<!-- FILE: book/chapters/part-09/chapter-05-cap-pacelc-and-consistency.md -->
## 9.5 - CAP, PACELC, and Consistency {#chapter-09-05}

CAP concerns a specific model: when a network partition prevents all nodes communicating, a replicated system cannot simultaneously guarantee every request a successful response and linearizable consistency. “Pick two” is misleading because partitions are a condition, not a normal feature to omit.

**Linearizability** makes each operation appear atomic between invocation and response, respecting real-time order. **Sequential consistency** preserves one global order consistent with each client’s program order but not necessarily real time. **Causal consistency** preserves cause-before-effect. **Eventual consistency** promises convergence only when updates stop and communication succeeds, and still needs conflict rules.

PACELC adds the normal case: if Partition, choose Availability or Consistency; Else, consider Latency versus Consistency. It is a reminder, not a product classifier.

Consistency should be stated per operation and invariant. A catalog search can be stale while inventory reservation must prevent oversell. Read-your-writes and monotonic reads may provide useful session guarantees without global linearizability.

::: {.interview-tip}
**Interview Tip**

Give a concrete concurrent history and allowed observation. Labels without an example invite category errors.
:::

<!-- FILE: book/chapters/part-09/chapter-06-time-in-distributed-systems.md -->
## 9.6 - Time in Distributed Systems {#chapter-09-06}

Wall clocks approximate civil time and can jump due to synchronization or administrative change. Monotonic clocks measure elapsed duration on one machine and should not move backward, but their readings are not comparable across hosts. Use wall time for human timestamps, monotonic time for local deadlines, and explicit logical order for causality.

NTP-style synchronization reduces error; it does not create perfect global time. Clock skew and uncertainty make “latest timestamp wins” a conflict policy that can discard a valid later action from a slow clock.

Lamport clocks assign counters so causal order implies increasing values, but equal ordering does not reveal concurrency fully. Vector clocks/version vectors track causality across participants at greater metadata cost. Hybrid logical clocks combine physical proximity with logical monotonicity under stated assumptions.

Deadlines should carry a remaining budget, not a wall-clock expiry blindly compared on another host. Expiration, leases, token validity, audit time, and event time each need their own semantics. Event-time streaming also distinguishes when an event occurred from when it arrived and uses watermarks to bound waiting for late data.

<!-- FILE: book/chapters/part-09/chapter-07-timeouts-retries-and-idempotency.md -->
## 9.7 - Timeouts, Retries, and Idempotency {#chapter-09-07}

A timeout bounds how long a caller waits; it does not cancel reality. Set it from an end-to-end deadline and observed latency distribution, leaving time for handling failure. Each downstream hop should receive a smaller remaining budget.

Retries improve success for transient, independent failures. They worsen overload and duplicate ambiguous mutations. Use a bounded attempt count, exponential backoff, jitter, retry classification, and a shared deadline. Limit retries with budgets so one failing dependency cannot multiply fleet traffic.

An idempotent operation has the same intended effect when repeated. HTTP method labels help but do not protect business effects. For creation or payment, accept a client-generated idempotency key, bind it to a request fingerprint and caller, store the durable outcome, and return that outcome on repetition. Define key lifetime and concurrent-request behavior.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant S as Service
    participant D as Deduplication store
    C->>S: Mutate, key K
    S->>D: Claim K + request hash
    D-->>S: New claim
    S->>D: Store committed outcome
    C->>S: Retry, same K
    S->>D: Read K
    D-->>S: Return prior outcome
~~~

*Diagram key: solid arrows = requests/state changes; dashed arrows = deduplication decisions.*

<!-- FILE: book/chapters/part-09/chapter-08-backpressure-and-overload-control.md -->
## 9.8 - Backpressure and Overload Control {#chapter-09-08}

When arrival rate exceeds sustainable completion rate, queues grow. Little’s Law (`L = λW`) relates average in-flight work, throughput, and time in a stable system. Once saturated, adding queue capacity usually converts rejection into worse latency and memory pressure.

Backpressure communicates limited capacity upstream. Techniques include bounded queues, concurrency limits, rate limits, pull-based flow, credit windows, and explicit overload responses. Admission should occur before expensive work and distinguish tenants or priorities where business policy requires it.

Load shedding preserves useful service by rejecting work unlikely to finish before its deadline. Circuit breakers stop repeated calls to a failing dependency; they require a meaningful fallback and cautious probing. Bulkheads isolate resources so one workload cannot exhaust all pools.

Adaptive concurrency can use observed queueing or latency, but feedback loops can oscillate. Bound them and test under bursts, slow dependencies, retry storms, and recovery. Autoscaling is slower than an overload event and needs headroom; it complements rather than replaces admission control.

::: {.interview-tip}
**Interview Tip**

Trace where work waits and who owns the queue. “Add a message queue” does not remove overload; it relocates and buffers it.
:::

<!-- FILE: book/chapters/part-09/chapter-09-caching-in-real-systems.md -->
## 9.9 - Caching in Real Systems {#chapter-09-09}

A cache trades freshness and complexity for lower latency, lower load, or availability. Define the key, value, authority, freshness, capacity, eviction, and behavior on failure before choosing a product.

Cache-aside reads the cache, loads the authority on miss, and writes the cache. Write-through updates cache and authority in one path but still has failure ordering. Write-behind improves write latency while risking loss and stale authority. Refresh-ahead hides misses for predictable hot data.

TTL limits age; it does not guarantee invalidation immediately or prevent an old writer repopulating stale data. Versioned keys, compare-and-set, event invalidation, and single-flight request coalescing address different races. Add jitter to expirations to prevent synchronized stampedes; use admission/eviction so scans do not evict the hot set.

Negative caching can protect a missing lookup but may hide newly created data. Distributed caches also introduce network latency, serialization, hot keys, and a new outage mode. A fallback to the database can turn cache failure into database failure, so bound fallback concurrency.

Cache hit rate alone is insufficient: measure saved origin work, hit latency, staleness, evictions, key skew, and behavior during cold start.

<!-- FILE: book/chapters/part-09/chapter-10-cross-system-consistency.md -->
## 9.10 - Cross-System Consistency {#chapter-09-10}

A local transaction cannot atomically update an independent database and broker by ordinary writes. Two-phase commit can coordinate prepared participants but has availability, blocking, and operational costs; many external systems do not support it.

The **transactional outbox** writes domain state and an outbox row in one database transaction. A relay publishes rows and marks progress; publication may repeat, so consumers remain idempotent. Change data capture can serve as the relay, but schema, ordering, replay, and connector operations become part of the contract.

~~~mermaid
flowchart LR
    api[Business transaction] --> db[(Domain rows + outbox)]
    db ==> relay[Outbox relay or CDC]
    relay -.-> log{{Event log}}
    log -.-> consumer[Idempotent consumer]
    consumer --> view[(Derived state)]
~~~

*Diagram key: cylinder = durable state; hexagon = async log; rectangles = active processes; thick arrow = sustained capture; dashed arrows = asynchronous delivery.*

A **saga** coordinates several local transactions through commands/events and compensating actions. Compensation is a new business action, not time travel: a refund may fail and cannot erase that an email was seen. Persist saga state, make steps idempotent, define deadlines, and provide reconciliation/manual repair.

The staff-level guarantee is often convergence with detection and repair, not impossible global atomicity.

<!-- FILE: book/chapters/part-09/chapter-11-high-availability-and-safe-lifecycle.md -->
## 9.11 - High Availability and Safe Lifecycle {#chapter-09-11}

High availability is an end-to-end property. Redundant instances behind one database, DNS zone, credential issuer, or deployment controller still share that dependency. Map failure domains and the control plane needed to recover them.

Safe startup requires dependency discovery, migrations compatible with mixed versions, and readiness only after the instance can serve correctly. Safe shutdown stops admission, marks unready, drains bounded work, transfers leases/partitions, flushes required state, and exits before forced termination.

Rolling deployments need backward- and forward-compatible protocols. Database changes follow expand/migrate/contract. Feature flags decouple exposure from deployment but require ownership, observability, expiry, and safe default behavior.

Failover is not complete at leader election: clients must discover the new endpoint, stale connections must fail, caches converge, capacity absorb traffic, and old leaders be fenced. Test RTO and RPO through restore and regional exercises, including control-plane impairment.

::: {.scenario}
**Real-World Scenario**

A regional failover succeeds technically, but the secondary region has cold caches and half the database connection limit. Retry traffic overwhelms it. Availability planning must include recovery load, not just idle replica count.
:::

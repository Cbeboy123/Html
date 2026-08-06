<!-- FILE: book/chapters/part-07/chapter-01-why-a-distributed-log-exists.md -->
## 7.1 - Why a Distributed Log Exists {#chapter-07-01}

A queue answers “who should do this work?” A distributed log answers a broader question: “what happened, in what order within a defined scope, and how may independent readers revisit it?” Records are appended rather than updated in place. Consumers retain their own positions, so one slow reader does not force every other reader to slow down.

The abstraction separates three concerns: producers publish facts, brokers retain ordered records, and consumers materialize their own views. This makes replay, fan-out, audit, and asynchronous integration natural. It also moves responsibility. Retention is finite, ordering is scoped, duplicates are possible, and a consumer must be able to rebuild or repair its state.

Kafka is best understood as a replicated, partitioned commit log. It is not a database replacement, an RPC transport, or a magic “exactly once” switch. The durable design question is whether an immutable fact plus replayable position is the right boundary.

::: {.scenario}
**Real-World Scenario**

An order service records `OrderAccepted`. Billing and fulfillment consume independently. If fulfillment is down for an hour, billing continues and fulfillment resumes from its last committed offset. The order database remains the authority; the log is the integration history.
:::

::: {.interview-tip}
**Interview Tip**

Name the reason for replay and the scope of ordering. “Kafka is fast messaging” describes an implementation outcome, not the architectural value.
:::

<!-- FILE: book/chapters/part-07/chapter-02-topics-partitions-records-and-offsets.md -->
## 7.2 - Topics, Partitions, Records, and Offsets {#chapter-07-02}

A **topic** is a named record stream divided into **partitions**. Within one partition, each appended record receives a monotonically increasing **offset**. The offset is a position, not a globally meaningful event identifier or timestamp.

~~~mermaid
flowchart LR
    p[Producer] -->|key = customer 42| route{Partitioner}
    route --> p0[(Partition 0: offsets 0..n)]
    route --> p1[(Partition 1: offsets 0..m)]
    route --> p2[(Partition 2: offsets 0..k)]
    p0 ==> c[Consumer-group member]
~~~

*Diagram key: rectangle = active client; diamond = routing decision; cylinders = retained logs; solid arrows = production; thick arrow = sustained consumption.*

The record key usually determines partition placement. All records for a stable key can therefore share partition order, provided the partition count and routing rules do not change incompatibly. There is no total order across partitions.

A record also carries a value, timestamp, and optional headers. Brokers retain records according to time/size policy or compaction; consuming does not delete them. Consumer offsets are separate state describing progress.

Partition count bounds parallelism within a consumer group and influences availability, metadata, file handles, recovery, and rebalance cost. More partitions are not free. Choose from target throughput, key cardinality, ordering requirements, and growth, then load-test the whole cluster.

::: {.gotcha}
**Gotcha**

Increasing partition count can remap keys under common partitioners. If per-key history must stay together, plan routing and migration explicitly.
:::

<!-- FILE: book/chapters/part-07/chapter-03-broker-and-cluster-anatomy.md -->
## 7.3 - Broker and Cluster Anatomy {#chapter-07-03}

A Kafka cluster contains brokers that store partition replicas and serve client requests. For each partition, one replica is the **leader**; producers and consumers ordinarily interact with that leader. Other replicas follow it and may become leader after failure.

Clients bootstrap from one or more addresses, fetch cluster metadata, and then connect directly to the relevant brokers. Bootstrap servers are discovery entry points, not permanent proxies. Incorrect advertised addresses therefore cause the puzzling pattern “bootstrap succeeds, produce fails.”

The controller coordinates cluster metadata and leadership. Modern Kafka uses the KRaft metadata quorum; ZooKeeper belongs to older deployments and migration history. Treat exact controller, election, and configuration details as version-specific.

Broker capacity has several dimensions: network, page cache, disk throughput and latency, request threads, replica movement, partition count, and controller workload. Balanced byte volume can still hide a hot leader or key.

::: {.key-terms}
**Key Terms**

Leader: replica serving a partition’s client traffic. Follower: replica copying the leader. ISR: replicas considered sufficiently caught up under configured rules. Controller quorum: replicated authority for cluster metadata.
:::

::: {.interview-tip}
**Interview Tip**

Draw client metadata discovery and per-partition leaders. Do not place a single “Kafka server” between all clients and data.
:::

<!-- FILE: book/chapters/part-07/chapter-04-the-producer-path.md -->
## 7.4 - The Producer Path {#chapter-07-04}

The producer serializes a record, chooses a partition, batches records per destination, and sends those batches to the current leader. Batching and compression amortize protocol and storage overhead; they improve throughput at the cost of memory and deliberate waiting.

~~~mermaid
flowchart LR
    app[Application record] --> ser[Serialize]
    ser --> part{Choose partition}
    part --> batch[Per-partition batch]
    batch --> leader[Partition leader]
    leader ==> followers[In-sync replicas]
    leader --x error{Retryable or fatal error}
~~~

*Diagram key: rectangles = active stages; diamond = routing; thick arrow = replication; cross-ended arrow = failed attempt.*

The acknowledgment setting defines when a send is considered successful. Waiting for all required in-sync replicas gives a stronger failure contract than leader-only acknowledgment, but cannot make every configuration durable. Minimum ISR, replication factor, leader-election policy, and storage failure all matter.

Retries can duplicate records unless idempotent production is enabled and its session guarantees remain intact. Ordering can also be affected by multiple in-flight requests and retries; modern clients mitigate common cases, but the contract remains configuration- and version-specific. A delivery callback means broker acceptance under the selected policy, not that a downstream consumer completed business work.

Backpressure is essential. When brokers slow, producer buffers fill. A bounded wait and explicit failure are safer than unbounded memory growth.

<!-- FILE: book/chapters/part-07/chapter-05-the-consumer-path.md -->
## 7.5 - The Consumer Path {#chapter-07-05}

Consumers pull batches from partition leaders. Pulling lets a consumer pace delivery and exploit batching, but the application must keep polling, process records, and manage progress correctly.

~~~mermaid
flowchart LR
    leader[(Partition leader)] ==> fetch[Fetch batches]
    fetch --> process[Process records]
    process --> effect[(Business effect)]
    process --> commit[Commit next offset]
    commit -.-> offsets[(Group offset store)]
~~~

*Diagram key: cylinders = retained state; rectangles = consumer stages; thick arrow = batched stream; dashed arrow = progress update.*

A committed offset normally represents the next record to read. Commit before the business effect risks loss; effect before commit risks repetition after a crash. The usual design accepts at-least-once delivery and makes the effect idempotent, or atomically coordinates effect and progress where the platform permits.

Automatic offset commit can be correct only when its timing matches processing. Long processing also interacts with group liveness. A robust consumer separates bounded fetching, processing, retry/quarantine, and commit policy while preserving order where required.

Lag is the distance between available and consumed positions. It is not itself elapsed time, and a stable offset lag can represent very different delay at different traffic rates. Monitor record lag, time lag where meaningful, processing latency, errors, and consumer saturation together.

<!-- FILE: book/chapters/part-07/chapter-06-rebalancing-and-consumer-failure.md -->
## 7.6 - Rebalancing and Consumer Failure {#chapter-07-06}

A consumer group assigns each partition to at most one active member at a time. Membership changes require assignments to move. This **rebalance** is a correctness protocol, not merely a performance pause: an old owner must stop before a new owner safely continues.

~~~mermaid
sequenceDiagram
    participant G as Group coordinator
    participant A as Consumer A
    participant B as Consumer B
    A->>G: Heartbeat; owns P0 and P1
    B->>G: Join group
    G-->>A: Revoke P1
    A->>A: Finish or stop work; commit safely
    G-->>B: Assign P1
    B->>B: Resume from committed offset
~~~

*Diagram key: solid arrows = membership messages; dashed arrows = assignment decisions; self-steps = local handoff work.*

Failures arise when processing exceeds the poll interval, heartbeats stop, deployments restart many members, or assignment takes too long. Repeated rebalances can prevent useful progress. Cooperative assignment reduces stop-the-world movement, while static membership can avoid churn for brief restarts; neither excuses stuck processing.

On revocation, stop creating new effects for the lost partitions, finish or cancel bounded work, and commit only offsets whose effects are complete. If processing is parallel, track contiguous completion; committing past a slow earlier record can skip it after failure.

::: {.interview-tip}
**Interview Tip**

Explain ownership transfer and the crash window. “Kafka redistributes load” omits the state that must be handed off safely.
:::

<!-- FILE: book/chapters/part-07/chapter-07-replication-and-recovery.md -->
## 7.7 - Replication and Recovery {#chapter-07-07}

Followers fetch the leader’s log and persist replicas. A partition’s in-sync replica set tracks followers eligible under configured freshness rules. When a leader fails, the controller elects a replacement from eligible replicas and clients refresh metadata.

~~~mermaid
flowchart TB
    leader[(Broker A: leader log)] ==> f1[(Broker B: follower)]
    leader ==> f2[(Broker C: follower)]
    controller[Metadata controller] -->|leader fails| election{Eligible replica?}
    election -->|B elected| f1
    election --x|none| unavailable{Partition unavailable}
~~~

*Diagram key: cylinders = replica logs; rectangle = controller; diamond = election condition; thick arrows = replication; cross-ended arrow = unavailable outcome.*

Replication provides a choice among latency, availability, and acknowledged-data risk. If the ISR falls below the configured minimum, strict production may reject writes rather than acknowledge under-replicated data. Allowing an out-of-sync replica to lead can restore availability by discarding a divergent tail; that is a conscious data-loss policy.

Recovery time depends on detection, election, metadata propagation, client retry, replica catch-up, and storage condition. A three-replica topic is not resilient if all replicas share one failure domain. Placement must cross the zones, racks, power, and operational boundaries the availability target assumes.

<!-- FILE: book/chapters/part-07/chapter-08-retention-deletion-and-log-compaction.md -->
## 7.8 - Retention, Deletion, and Log Compaction {#chapter-07-08}

Time/size retention deletes old log segments regardless of whether every consumer processed them. Retention is therefore a storage policy, not an acknowledgment protocol. A consumer whose outage exceeds retention must recover from another source or accept a gap.

**Log compaction** retains the latest record for each key eventually, while preserving ordering of retained records and allowing old values to remain until compaction runs. A tombstone marks deletion; tombstones themselves need a retention window so replicas and offline consumers can observe the delete.

Compaction enables changelog and state-rebuild patterns, not a point-in-time database snapshot. Keys are part of the data model: changing serialization or key meaning can strand historical state. Null keys, large keys, skew, and high update churn also affect storage behavior.

Choose policy from recovery needs:

| Need | Suitable basis |
|---|---|
| Replay every recent event | Time/size retention |
| Rebuild latest keyed state | Compaction |
| Both recent history and long-lived latest state | Combined policy, tested carefully |

Capacity planning includes retained bytes, replication factor, segment overhead, temporary compaction space, and replica movement headroom.

<!-- FILE: book/chapters/part-07/chapter-09-storage-and-throughput-mechanics.md -->
## 7.9 - Storage and Throughput Mechanics {#chapter-07-09}

Kafka’s throughput comes from a cooperative design: append-oriented files, large sequential operations, batching, compression, OS page cache, and direct transfer paths where supported. It is not evidence that disks or durability no longer matter.

Records are grouped into batches and log segments with index files. Reads often come from the page cache; cold reads compete for storage and can evict useful pages. Many small partitions create metadata, file, recovery, and cache overhead even at low byte volume.

The relevant capacity equation is end-to-end. Ingress is multiplied by replicas; consumers add egress; reassignments and recovery add temporary read/write traffic. Compression reduces network and storage but consumes producer and consumer CPU. Large batches amortize work but raise latency and failure blast radius.

Benchmark representative key distribution, record size, compression, acknowledgment policy, consumer count, retention, and failure recovery. A steady-state peak test that never loses a broker does not validate operability.

::: {.gotcha}
**Gotcha**

High disk utilization is not the diagnosis. Distinguish throughput saturation, latency, queue depth, page-cache misses, replica catch-up, and another tenant’s I/O.
:::

<!-- FILE: book/chapters/part-07/chapter-10-delivery-semantics-and-transactions.md -->
## 7.10 - Delivery Semantics and Transactions {#chapter-07-10}

At-most-once permits loss but avoids broker redelivery; at-least-once avoids silent loss under the covered failures but permits duplicates; exactly-once requires a precisely bounded transaction. These labels describe an end-to-end effect only when every boundary participates.

Kafka idempotent production suppresses duplicates from producer retries within its defined session. Kafka transactions can atomically publish to several partitions and commit consumed offsets with produced output. Consumers using the appropriate isolation avoid aborted transactional records. This supports consume-transform-produce pipelines inside Kafka.

It does not atomically include an arbitrary database, email, payment provider, or side effect. For those, use idempotency keys, an inbox/deduplication table, an outbox, or reconciliation. “Exactly once” is not a property a broker can grant to external reality.

~~~mermaid
sequenceDiagram
    participant C as Consumer/producer
    participant K as Kafka transaction
    C->>K: Begin
    C->>K: Read input and publish outputs
    C->>K: Send consumed offsets
    C->>K: Commit transaction
    K-->>C: Outputs and offsets visible atomically
~~~

*Diagram key: solid arrows = transactional operations; dashed arrow = atomic visibility result inside Kafka’s transaction scope.*

<!-- FILE: book/chapters/part-07/chapter-11-metadata-evolution-zookeeper-and-kraft.md -->
## 7.11 - Metadata Evolution: ZooKeeper and KRaft {#chapter-07-11}

Cluster metadata includes brokers, topics, partitions, replicas, leadership, and configuration. It needs one ordered, fault-tolerant authority. Older Kafka architectures used ZooKeeper plus Kafka controllers; current architecture uses a Kafka-native Raft metadata quorum, commonly called **KRaft**.

KRaft controllers replicate an ordered metadata log. A leader handles changes; a majority quorum establishes committed metadata, and brokers follow the resulting image. This removes the split operational model of Kafka plus ZooKeeper, but it does not remove quorum design, controller sizing, backup, monitoring, or safe upgrades.

Metadata-plane failure differs from data-plane failure. Existing leaders may serve some traffic while topic creation, elections, or configuration changes stall. Diagnose controller quorum health separately from partition replication and client connectivity.

Migration and feature availability are release-specific. Preserve these durable rules: follow the exact supported upgrade path, change one compatibility boundary at a time, verify rollback limits, and never infer quorum safety from process count alone. A three-voter quorum tolerates one unavailable voter only when the remaining two can communicate and have valid state.

::: {.interview-tip}
**Interview Tip**

Explain why metadata itself needs consensus. ZooKeeper versus KRaft is an architectural evolution, not merely a configuration rename.
:::

<!-- FILE: book/chapters/part-07/chapter-12-operating-kafka.md -->
## 7.12 - Operating Kafka {#chapter-07-12}

Operate Kafka through service-level symptoms and causal signals. Useful views include produce/fetch latency and errors, request queues, bytes, under-replicated or offline partitions, ISR changes, controller quorum health, storage latency/capacity, consumer lag, and rebalance rate.

Alert on conditions that threaten a user guarantee, not every moving counter. One under-replicated partition may be routine during maintenance; a growing set plus shrinking disk headroom is urgent. Consumer lag may be acceptable for analytics and an outage for fraud detection.

Safe lifecycle work includes partition-aware rolling restarts, leadership checks, bounded replica movement, capacity headroom, and testing a broker or zone loss. Reassignment moves real bytes and can harm foreground traffic. Quotas and admission control prevent one client from turning a local error into cluster overload.

Runbooks should answer: which guarantee is at risk, which partitions/clients are affected, what changed, what evidence distinguishes broker from client trouble, and which action is reversible. Preserve logs and timelines before “fixing” the evidence.

Backups of configuration and metadata complement, but do not replace, replication. If Kafka is the only copy of irreplaceable events, retention, disaster recovery, and restoration must be tested as a data product.

<!-- FILE: book/chapters/part-07/chapter-13-kafka-interview-synthesis.md -->
## 7.13 - Kafka Interview Synthesis {#chapter-07-13}

A staff-level Kafka answer moves from requirement to invariant to mechanism:

1. Define event meaning, authority, key, and ordering scope.
2. Choose partitions from parallelism, throughput, and future routing.
3. State replication and acknowledgment policy with its failure tradeoff.
4. Trace produce, broker commit, fetch, effect, offset commit, and every crash window.
5. Bound retries, poison records, lag, retention, and recovery.
6. Name observability and a safe operational test.

For an order pipeline, a strong answer says orders are keyed by order ID, ordered only per order, produced idempotently with sufficient replica acknowledgment, consumed at least once, applied through an idempotent business key, and quarantined after classified retry. It explains how to rebuild state and what happens when an outage exceeds retention.

Avoid claims such as “Kafka guarantees ordering,” “replication means no loss,” or “transactions make database writes exactly once.” Each is missing scope.

::: {.interview-tip}
**Interview Tip**

When pressed for a configuration value, state the governing workload and guarantee first. Exact batch sizes, timeouts, and partition counts are measurements, not wisdom.
:::

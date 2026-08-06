# Glossary {.unnumbered}

**Acknowledgment (ack).** Evidence that a receiver reached a defined protocol point. Qualify it: received, persisted, replicated, committed, and processed are different.

**Atomicity.** A logical effect occurs as a unit or not at all within a stated transactional boundary.

**Authentication / authorization.** Establishing a principal's identity / deciding whether that principal may act on a resource in context.

**Backpressure.** Communication of limited downstream capacity so upstream work can slow, stop, or be rejected before queues become unsafe.

**Cache coherence.** Hardware mechanisms that keep cached copies of a memory location from remaining incompatibly divergent; not a language memory model.

**CAP.** Under a network partition, a replicated system cannot guarantee both a successful response to every request and linearizable consistency.

**Cardinality estimate.** An optimizer's predicted number of rows at a plan operator; large errors often lead to poor physical plans.

**Causal consistency.** A model preserving cause-before-effect while permitting concurrent operations to be observed in different orders.

**Checkpoint.** Database recovery metadata and coordinated progress limiting how much history recovery examines; not necessarily an instantaneous flush.

**Circuit breaker.** A control that temporarily stops calls to a failing dependency and cautiously probes for recovery.

**Commit log.** An append-oriented ordered record of accepted changes used for replication, replay, or recovery.

**Compaction.** Rewriting retained state to remove obsolete representation; in a keyed log, eventually retaining the latest record per key under policy.

**Concurrency / parallelism.** Overlapping progress / simultaneous execution on multiple processing units.

**Consensus.** Agreement among nodes on a value or ordered sequence despite failures covered by the protocol's model.

**Consistency model.** Rules describing which values concurrent or distributed operations may observe; distinct from ACID consistency.

**Consumer group.** Consumers dividing partition ownership so one partition has at most one active owner in the group at a time.

**Deadline.** Time budget after which an outcome is no longer useful. It bounds all attempts rather than restarting on each retry.

**Deadlock.** A stable wait cycle in which participants cannot make progress.

**Durability.** Survival of acknowledged effects under explicitly covered failures and configuration.

**Endianness.** Byte order used to represent a multi-byte value.

**Error budget.** Unreliability implied by an SLO and available for controlled change or unavoidable failure.

**Eventual consistency.** Convergence promised after updates stop and communication succeeds, under an explicit conflict rule.

**Fencing token.** Monotonically increasing authority value that lets a resource reject actions from a stale leader or lease holder.

**Flow control.** Prevention of a sender overwhelming receiver capacity; distinct from network congestion control.

**Forward secrecy.** Later compromise of a long-term key does not itself reveal past sessions established with suitable ephemeral key agreement.

**Happens-before.** A formal ordering relation providing specified visibility between concurrent actions.

**Idempotency.** Repetition has the same intended effect as one application; responses need not be identical.

**Index.** Maintained access structure trading storage and write work for faster selected reads.

**Isolation.** A database's rules for observations and conflicts among concurrent transactions.

**Latency / throughput.** Time for one outcome / completed outcomes per unit time.

**Leader.** Replica with current protocol authority to order or serve selected operations. Safe leadership requires election and often fencing.

**Linearizability.** Operations appear atomic between invocation and response and respect real-time precedence.

**Liveness / safety.** Useful progress eventually occurs / prohibited outcomes never occur, under stated assumptions.

**Memory model.** Language/runtime rules for permitted observations, ordering, and synchronization of shared memory.

**Monotonic clock.** Local clock suited to elapsed duration because it does not move backward; readings are not comparable across hosts.

**MVCC.** Multi-version concurrency control: retaining versions so reads can use snapshots while writes proceed under engine rules.

**Offset.** A consumer/log position within one partition; not a global event identifier.

**Overload.** Demand beyond sustainable capacity, causing queue growth, latency, rejection, or failure.

**Page fault.** OS handling required when a virtual-memory mapping cannot be completed directly; not always an error.

**Partition (data).** A managed subset of data or a log. Ordering and ownership are commonly scoped to it.

**Partition (network).** Communication failure dividing nodes that may each remain alive.

**Quorum.** Participants sufficient under protocol rules to decide or acknowledge an operation, usually chosen to intersect competing decisions.

**Rebalance.** Transfer of partition assignments among consumer-group members.

**RPO / RTO.** Maximum tolerable data-loss interval / target time to restore a defined service.

**Replication.** Maintaining live copies for availability, locality, scale, or durability; not a historical backup.

**Saga.** Coordination of local transactions through durable progress and compensating business actions rather than one global transaction.

**Serialization.** Conversion of values into bytes under a schema; in concurrency, equivalence to a serial order.

**SLA / SLI / SLO.** External commitment / measured service indicator / target level for that indicator.

**Tail latency.** Slow end of a latency distribution, often driven by queueing, contention, retries, or rare paths.

**Timeout.** Bound on how long an observer waits; it neither proves failure nor guarantees remote cancellation.

**TLS termination.** Endpoint where protected TLS records become plaintext and authenticated transport identity is evaluated.

**Transaction.** Unit of operations with guarantees defined by the participating system.

**Trust boundary.** Point where identity, data, or control enters a different assurance or ownership domain and must be revalidated.

**Unicode / UTF-8.** Unicode defines code points and text semantics; UTF-8 maps code points to variable-length bytes.

**Virtual memory.** Per-process address spaces translated to physical frames or backing by hardware and the OS.

**Write-ahead log (WAL).** Recovery information made durable before corresponding data-page changes may persist under the engine's protocol.

**Admission control.** A decision made before expensive work begins to accept, delay, or reject work according to available capacity and policy.

**Baggage.** Small contextual values propagated with distributed telemetry. Baggage is not automatically safe for secrets or high-volume data.

**Cardinality.** The number of distinct values in a set. High-cardinality metric labels can create large storage and processing cost.

**Compensating action.** A new business action that reduces or reverses the effect of an earlier committed action; it does not erase history.

**Contiguous offset.** Highest progress position for which every earlier required record is complete. Gaps matter when consumer work runs in parallel.

**Epoch / term.** Monotonically increasing leadership generation used by a protocol to distinguish current authority from stale authority.

**Fan-out.** One operation starting several downstream operations, often amplifying tail latency and failure probability.

**Headroom.** Capacity intentionally left unused during normal operation so bursts, failures, and recovery work can be absorbed.

**Idempotency key.** Stable identifier for one logical mutation, allowing repeated network attempts to return or preserve one business effect.

**Inbox / outbox.** Durable integration patterns: an inbox deduplicates consumed events near an effect; an outbox records events beside authoritative state for later publication.

**Lease.** Time-limited grant of authority. A lease alone needs fencing when an expired holder can resume and act.

**Predicate lock.** Database mechanism that tracks or protects a set defined by a search condition rather than only currently existing rows; details are product-specific.

**Queue time.** Time work waits before active service begins.

**Reconciliation.** Comparing states or outcomes to detect and repair divergence after partial failure.

**Saturation.** A resource has reached the point where additional demand mainly increases waiting, rejection, or failure.

**Serialization failure.** Database abort indicating that a concurrent transaction cannot safely commit under the requested isolation model; the whole transaction is normally retried.

**Serialization point.** The operation or decision that establishes one authoritative order for competing state changes.

**Service time.** Time a resource actively spends processing work, excluding time waiting in its queue.

**Structured concurrency.** Organizing concurrent work so child-task lifetime, cancellation, errors, and resource ownership remain bounded by an enclosing operation.

**Tail amplification.** A small slow-request probability at one dependency becoming a much larger top-level probability through fan-out or repeated stages.

**Telemetry.** Evidence emitted by a system, including traces, metrics, logs, events, baggage, and profiles.

**Write skew.** Concurrent transactions read a shared condition, update different items, and together violate an invariant without a direct write-write conflict.

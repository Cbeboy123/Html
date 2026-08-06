## 13.6 - Kafka End-to-End Correctness {#chapter-13-06}

Kafka is easiest to reason about as a set of ordered partition logs plus independently stored consumer progress. “Message sent” is not one moment. Trace the whole record lifecycle.

### Produce path

1. The producer serializes the key and value.
2. A partitioner chooses a partition, often from the key.
3. Records form a compressed batch.
4. The batch goes to the current partition leader.
5. Followers copy the leader's log.
6. The leader acknowledges according to producer and broker policy.

An acknowledgment means the broker reached the configured point. It does not mean a consumer applied the business effect. Durability depends on replication factor, in-sync replica rules, acknowledgment policy, storage, placement, and leader-election policy together.

Kafka 4.1 enables idempotent producer behavior by default under compatible settings. Idempotence prevents duplicates created by supported producer retries within its defined session. It cannot deduplicate an application that creates and sends the same business event twice with different sends or identifiers.

### Consumer path and crash windows

The consumer fetches records, applies effects, and commits progress. The committed offset usually names the next record to read.

| Order of steps | Crash result |
|---|---|
| Commit offset, then effect | Record can be skipped: progress says done before effect |
| Effect, then commit offset | Record can repeat: effect exists but progress was not saved |
| Effect and progress in one participating transaction | Atomic only inside that transaction's scope |

For an external database, a common pattern is an inbox or deduplication table. In one database transaction, claim the event's stable ID, apply the business effect, and record completion. A repeated record finds the existing claim/result and does not repeat the effect.

### Ordering is narrower than it sounds

Kafka orders records within one partition. It does not provide a total order across a topic's partitions. Concurrent consumers can also finish effects out of order unless processing is serialized where order matters.

Choose the record key from the entity whose order must be preserved, such as order ID or account ID. A hot key can become a hot partition, so the ordering model is also a capacity decision.

::: {.fact}
**Worth Knowing - More partitions can change both order and routing**

Increasing a topic's partition count raises possible parallelism, but common partitioning functions may map existing keys to different partitions after the change. Historical records for one key can then exist in two partitions. Plan key routing and migration when long-lived per-key order matters.
:::

### Rebalance is a state handoff

When group membership changes, partition ownership moves. The old owner must stop producing effects for revoked partitions before the new owner safely resumes from committed progress.

If processing is parallel, commit only the highest **contiguous** completed offset. Suppose offsets 10 and 12 finish while 11 is still running. Committing past 12 can skip 11 after a crash. Track gaps or limit per-partition concurrency.

Repeated rebalances often come from processing that exceeds the poll interval, blocked heartbeats, mass restarts, or slow assignment callbacks. Monitor rebalance rate and time, processing duration, poll health, and lag together.

### Kafka transactions: powerful but scoped

A transactional producer can publish output records and consumed offsets atomically across participating Kafka partitions. Consumers configured to read committed data avoid aborted output. This is well suited to consume-transform-produce work inside Kafka.

It does not include an arbitrary database, email, payment provider, or file. Those effects require idempotency, outbox/inbox, provider status, or reconciliation.

Kafka 4.x uses KRaft for cluster metadata. The controller quorum orders metadata changes. It does not carry ordinary topic data, and losing a metadata quorum is different from losing one partition leader. Monitor controller quorum and partition replication separately.

### Lag and retention

Offset lag is a count of records, not a duration. Ten thousand records may be seconds at one traffic rate and hours at another. Track time-to-process or event age where the business cares about delay.

Retention can delete records whether or not a consumer read them. A consumer outage longer than retention needs another recovery source or accepts a gap. Compaction eventually keeps the latest value per key under policy; it is not an instant snapshot.

### Operational checklist

- Stable event meaning, schema, ID, key, and owner
- Required partition ordering and expected hot keys
- Producer acknowledgment and error handling
- Consumer effect/offset crash-window strategy
- Poison-record classification, bounded retry, quarantine, and replay
- Retention longer than tested recovery time
- Replica placement across real failure domains
- Broker/partition capacity and recovery headroom
- Rebalance, lag, under-replication, storage, and controller signals

::: {.interview-tip}
**Staff-Level Answer**

Trace one record through partition choice, leader acknowledgment, replica state, consumer effect, offset commit, crash, and replay. End by stating exactly where the guarantee stops.
:::


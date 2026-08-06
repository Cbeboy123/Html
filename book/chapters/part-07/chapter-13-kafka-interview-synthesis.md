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

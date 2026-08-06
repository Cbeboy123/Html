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

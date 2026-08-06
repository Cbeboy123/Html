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

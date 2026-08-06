## 7.12 - Operating Kafka {#chapter-07-12}

Operate Kafka through service-level symptoms and causal signals. Useful views include produce/fetch latency and errors, request queues, bytes, under-replicated or offline partitions, ISR changes, controller quorum health, storage latency/capacity, consumer lag, and rebalance rate.

Alert on conditions that threaten a user guarantee, not every moving counter. One under-replicated partition may be routine during maintenance; a growing set plus shrinking disk headroom is urgent. Consumer lag may be acceptable for analytics and an outage for fraud detection.

Safe lifecycle work includes partition-aware rolling restarts, leadership checks, bounded replica movement, capacity headroom, and testing a broker or zone loss. Reassignment moves real bytes and can harm foreground traffic. Quotas and admission control prevent one client from turning a local error into cluster overload.

Runbooks should answer: which guarantee is at risk, which partitions/clients are affected, what changed, what evidence distinguishes broker from client trouble, and which action is reversible. Preserve logs and timelines before “fixing” the evidence.

Backups of configuration and metadata complement, but do not replace, replication. If Kafka is the only copy of irreplaceable events, retention, disaster recovery, and restoration must be tested as a data product.

## 7.11 - Metadata Evolution: ZooKeeper and KRaft {#chapter-07-11}

Cluster metadata includes brokers, topics, partitions, replicas, leadership, and configuration. It needs one ordered, fault-tolerant authority. Older Kafka architectures used ZooKeeper plus Kafka controllers; current architecture uses a Kafka-native Raft metadata quorum, commonly called **KRaft**.

KRaft controllers replicate an ordered metadata log. A leader handles changes; a majority quorum establishes committed metadata, and brokers follow the resulting image. This removes the split operational model of Kafka plus ZooKeeper, but it does not remove quorum design, controller sizing, backup, monitoring, or safe upgrades.

Metadata-plane failure differs from data-plane failure. Existing leaders may serve some traffic while topic creation, elections, or configuration changes stall. Diagnose controller quorum health separately from partition replication and client connectivity.

Migration and feature availability are release-specific. Preserve these durable rules: follow the exact supported upgrade path, change one compatibility boundary at a time, verify rollback limits, and never infer quorum safety from process count alone. A three-voter quorum tolerates one unavailable voter only when the remaining two can communicate and have valid state.

::: {.interview-tip}
**Interview Tip**

Explain why metadata itself needs consensus. ZooKeeper versus KRaft is an architectural evolution, not merely a configuration rename.
:::

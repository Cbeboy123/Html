## 6.8 - Scaling and Protecting Data {#chapter-06-08}

**Partitioning** divides data into managed subsets. It can prune work and improve
maintenance, but a query that ignores the partition key may touch every subset.

**Replication** copies data to other nodes for availability, locality, or read
capacity. Replication lag makes replicas stale. Synchronous acknowledgment can
improve durability while increasing latency or reducing availability during
failure; exact guarantees depend on the protocol and configuration.

**Sharding** distributes ownership of different data across nodes. The shard key
determines routing and hotspot risk. Cross-shard joins, uniqueness, transactions,
and rebalancing become distributed problems.

Failover must prevent split brain and stale-primary writes. Promotion also
changes connection routing and may lose acknowledged work if the durability
contract allowed lag. Test the actual recovery procedure.

Backups protect against failures replication does not: accidental deletion,
logical corruption, or compromise. A backup is useful only if it can be
restored. Define **RPO** (maximum tolerable data-loss interval) and **RTO**
(target time to restore service) as business objectives, then test restore time
and recovered consistency.

::: {.interview-tip}
**Interview Tip**

For each scaling mechanism, name the new coordination cost. Partitioning,
replication, and sharding solve different problems.
:::

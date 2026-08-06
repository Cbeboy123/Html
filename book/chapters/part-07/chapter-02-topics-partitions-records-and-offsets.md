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

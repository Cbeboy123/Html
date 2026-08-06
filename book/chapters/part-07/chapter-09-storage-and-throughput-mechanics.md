## 7.9 - Storage and Throughput Mechanics {#chapter-07-09}

Kafka’s throughput comes from a cooperative design: append-oriented files, large sequential operations, batching, compression, OS page cache, and direct transfer paths where supported. It is not evidence that disks or durability no longer matter.

Records are grouped into batches and log segments with index files. Reads often come from the page cache; cold reads compete for storage and can evict useful pages. Many small partitions create metadata, file, recovery, and cache overhead even at low byte volume.

The relevant capacity equation is end-to-end. Ingress is multiplied by replicas; consumers add egress; reassignments and recovery add temporary read/write traffic. Compression reduces network and storage but consumes producer and consumer CPU. Large batches amortize work but raise latency and failure blast radius.

Benchmark representative key distribution, record size, compression, acknowledgment policy, consumer count, retention, and failure recovery. A steady-state peak test that never loses a broker does not validate operability.

::: {.gotcha}
**Gotcha**

High disk utilization is not the diagnosis. Distinguish throughput saturation, latency, queue depth, page-cache misses, replica catch-up, and another tenant’s I/O.
:::

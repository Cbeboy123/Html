## 7.3 - Broker and Cluster Anatomy {#chapter-07-03}

A Kafka cluster contains brokers that store partition replicas and serve client requests. For each partition, one replica is the **leader**; producers and consumers ordinarily interact with that leader. Other replicas follow it and may become leader after failure.

Clients bootstrap from one or more addresses, fetch cluster metadata, and then connect directly to the relevant brokers. Bootstrap servers are discovery entry points, not permanent proxies. Incorrect advertised addresses therefore cause the puzzling pattern “bootstrap succeeds, produce fails.”

The controller coordinates cluster metadata and leadership. Modern Kafka uses the KRaft metadata quorum; ZooKeeper belongs to older deployments and migration history. Treat exact controller, election, and configuration details as version-specific.

Broker capacity has several dimensions: network, page cache, disk throughput and latency, request threads, replica movement, partition count, and controller workload. Balanced byte volume can still hide a hot leader or key.

::: {.key-terms}
**Key Terms**

Leader: replica serving a partition’s client traffic. Follower: replica copying the leader. ISR: replicas considered sufficiently caught up under configured rules. Controller quorum: replicated authority for cluster metadata.
:::

::: {.interview-tip}
**Interview Tip**

Draw client metadata discovery and per-partition leaders. Do not place a single “Kafka server” between all clients and data.
:::

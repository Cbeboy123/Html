## 12.2 - Contrast Tables That Prevent Category Errors {#chapter-12-02}

| Often confused | Correct distinction |
|---|---|
| Concurrency / parallelism | Overlapping progress / simultaneous execution |
| Latency / throughput | Time per outcome / outcomes per unit time |
| Process / thread | Protected resource container / execution sequence sharing process resources |
| Cache coherence / memory consistency | Agreement on cached copies / permitted observation and ordering |
| Atomicity / durability | All-or-nothing logical effect / survival under covered failures |
| MVCC / serializability | Versioning mechanism / outcome-equivalence guarantee |
| Partitioning / sharding | Dividing data / distributing ownership across nodes |
| Replication / backup | Live redundant copies / recoverable historical copy |
| Authentication / authorization | Establish identity / permit an action |
| Hash / encryption | One-way digest / reversible confidentiality with a key |
| Safe / idempotent HTTP method | Intended not to change state / repeated requested effect is the same |
| Queue / retained log | Competing work handoff / replayable ordered record stream |
| Delivery / processing semantics | Broker-to-consumer behavior / end-to-end business effect |
| Timeout / cancellation | Caller stops waiting / work is asked or forced to stop |
| Availability / correctness | Service answers / answer satisfies the contract |
| Readiness / liveness | Safe to route / restart may restore progress |
| Log / metric / trace | Discrete event / numeric aggregation / causal request path |
| Deployment / release | Install code / expose behavior |

When two terms seem interchangeable, ask: what is the scope, clock, failure model, and observer? The distinction usually appears at a boundary.

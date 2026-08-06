## 9.1 - Why Distribution Changes the Rules {#chapter-09-01}

Inside one process, memory is shared and failure is often obvious. Across machines, messages take time, can be lost or duplicated, and reveal no perfect distinction between a slow peer, a broken link, and a failed peer. Nodes restart with different knowledge; clocks disagree; operators change the system while it runs.

The central fact is **partial failure**: one component can fail while others continue. A caller that times out does not know whether the request was never received, is still executing, or committed and lost its response. Every remote mutation therefore needs an ambiguity strategy: idempotency, status lookup, deduplication, or reconciliation.

Distribution is justified by availability, scale, geography, isolation, or organizational boundaries—not fashion. It introduces serialization, compatibility windows, network policy, independent queues, and operational coordination.

::: {.key-terms}
**Key Terms**

Safety means nothing bad happens (for example, two primaries do not both commit conflicting ownership). Liveness means useful progress eventually occurs. A design must state assumptions—failure type, timing, quorum, and storage durability—before claiming either.
:::

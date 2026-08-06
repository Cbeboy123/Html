## 7.6 - Rebalancing and Consumer Failure {#chapter-07-06}

A consumer group assigns each partition to at most one active member at a time. Membership changes require assignments to move. This **rebalance** is a correctness protocol, not merely a performance pause: an old owner must stop before a new owner safely continues.

~~~mermaid
sequenceDiagram
    participant G as Group coordinator
    participant A as Consumer A
    participant B as Consumer B
    A->>G: Heartbeat; owns P0 and P1
    B->>G: Join group
    G-->>A: Revoke P1
    A->>A: Finish or stop work; commit safely
    G-->>B: Assign P1
    B->>B: Resume from committed offset
~~~

*Diagram key: solid arrows = membership messages; dashed arrows = assignment decisions; self-steps = local handoff work.*

Failures arise when processing exceeds the poll interval, heartbeats stop, deployments restart many members, or assignment takes too long. Repeated rebalances can prevent useful progress. Cooperative assignment reduces stop-the-world movement, while static membership can avoid churn for brief restarts; neither excuses stuck processing.

On revocation, stop creating new effects for the lost partitions, finish or cancel bounded work, and commit only offsets whose effects are complete. If processing is parallel, track contiguous completion; committing past a slow earlier record can skip it after failure.

::: {.interview-tip}
**Interview Tip**

Explain ownership transfer and the crash window. “Kafka redistributes load” omits the state that must be handed off safely.
:::

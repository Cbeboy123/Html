## 9.5 - CAP, PACELC, and Consistency {#chapter-09-05}

CAP concerns a specific model: when a network partition prevents all nodes communicating, a replicated system cannot simultaneously guarantee every request a successful response and linearizable consistency. “Pick two” is misleading because partitions are a condition, not a normal feature to omit.

**Linearizability** makes each operation appear atomic between invocation and response, respecting real-time order. **Sequential consistency** preserves one global order consistent with each client’s program order but not necessarily real time. **Causal consistency** preserves cause-before-effect. **Eventual consistency** promises convergence only when updates stop and communication succeeds, and still needs conflict rules.

PACELC adds the normal case: if Partition, choose Availability or Consistency; Else, consider Latency versus Consistency. It is a reminder, not a product classifier.

Consistency should be stated per operation and invariant. A catalog search can be stale while inventory reservation must prevent oversell. Read-your-writes and monotonic reads may provide useful session guarantees without global linearizability.

::: {.interview-tip}
**Interview Tip**

Give a concrete concurrent history and allowed observation. Labels without an example invite category errors.
:::

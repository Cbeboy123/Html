## 12.1 - How to Build a Senior-Level Answer {#chapter-12-01}

A strong technical answer is a compact model, not a fact dump. Use this sequence:

1. **Frame:** restate the goal, scope, workload, and non-goals.
2. **Define:** give precise terms and the guarantee boundary.
3. **Mechanism:** trace the normal path in causal order.
4. **Failure:** examine concurrency, partial failure, overload, and recovery.
5. **Tradeoff:** name what improves and what becomes harder.
6. **Evidence:** specify measurements, tests, and operational signals.
7. **Decision:** recommend under stated assumptions and identify what would change it.

Layer detail progressively. Begin with the invariant and a simple path; expand only where the interviewer or decision needs depth. Distinguish universal principles from product/version behavior. Say “I would verify” when a default is not the point.

For “How does a database commit work?” define the durability contract, trace WAL before dirty-page flush, explain crash recovery and ambiguous acknowledgment, then discuss replication/configuration. For “How would you add retries?” start from idempotency and deadline, not a library annotation.

::: {.interview-tip}
**Interview Tip**

End with an explicit recommendation. An endless list of tradeoffs avoids the engineering decision.
:::

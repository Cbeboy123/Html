## 7.1 - Why a Distributed Log Exists {#chapter-07-01}

A queue answers “who should do this work?” A distributed log answers a broader question: “what happened, in what order within a defined scope, and how may independent readers revisit it?” Records are appended rather than updated in place. Consumers retain their own positions, so one slow reader does not force every other reader to slow down.

The abstraction separates three concerns: producers publish facts, brokers retain ordered records, and consumers materialize their own views. This makes replay, fan-out, audit, and asynchronous integration natural. It also moves responsibility. Retention is finite, ordering is scoped, duplicates are possible, and a consumer must be able to rebuild or repair its state.

Kafka is best understood as a replicated, partitioned commit log. It is not a database replacement, an RPC transport, or a magic “exactly once” switch. The durable design question is whether an immutable fact plus replayable position is the right boundary.

::: {.scenario}
**Real-World Scenario**

An order service records `OrderAccepted`. Billing and fulfillment consume independently. If fulfillment is down for an hour, billing continues and fulfillment resumes from its last committed offset. The order database remains the authority; the log is the integration history.
:::

::: {.interview-tip}
**Interview Tip**

Name the reason for replay and the scope of ordering. “Kafka is fast messaging” describes an implementation outcome, not the architectural value.
:::

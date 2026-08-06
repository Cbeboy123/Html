## 6.3 - Normalization and Deliberate Denormalization {#chapter-06-03}

Normalization separates facts so one fact has one authoritative place to change.
A **functional dependency** means one set of attributes determines another.
Normal forms use such dependencies to avoid update, insertion, and deletion
anomalies.

For example, repeating a customer address on every order line makes an address
change a multi-row operation and leaves unclear whether history or current state
is intended. Separating customer, order, and order-line facts clarifies the
invariants.

Normalization is not “more tables is always better.” The design follows facts
and dependencies. Over-fragmenting concepts can make invariants harder to
express and queries harder to operate.

**Denormalization** deliberately stores derived or repeated data to improve a
known access pattern. It introduces a consistency protocol: who updates the
copies, whether updates are synchronous, how stale data may be, and how repair
works. A materialized view, search index, cache, or event projection is a
denormalized representation even when it lives outside the primary database.

Before denormalizing, verify the bottleneck with an execution plan and workload.
Indexes, query changes, batching, or precomputed summaries may solve the problem
with a clearer consistency boundary.

::: {.interview-tip}
**Interview Tip**

Name the anomaly normalization prevents and the consistency protocol
denormalization requires. “Normalize writes, denormalize reads” is too broad.
:::

## 6.4 - Transactions and ACID {#chapter-06-04}

A **transaction** groups operations into a unit with guarantees defined by the
database. ACID is a vocabulary, not one universal implementation.

- **Atomicity:** the transaction’s changes take effect as a unit or not at all.
- **Consistency:** a committed transaction preserves declared invariants when
  application logic and constraints are correct.
- **Isolation:** concurrent transactions behave according to an isolation model.
- **Durability:** committed effects survive failures covered by the configured
  durability contract.

Consistency in ACID is not the same term as distributed replica consistency.
Atomicity does not mean all physical writes occur at one instant. Durability may
depend on storage, replication acknowledgment, and configuration.

Transactions begin, read/write, and commit or roll back. Commit can still return
an ambiguous result if the connection fails after the server decides to commit.
Blind retry can duplicate a business operation unless it has an idempotency key
or a status/reconciliation path.

Keep transactions long enough to protect the invariant and short enough to
avoid unnecessary locks, version retention, and resource occupancy. Never hold
a database transaction open while waiting for user input or an uncontrolled
remote call.

::: {.interview-tip}
**Interview Tip**

Tie each ACID letter to a failure or concurrency mechanism. Avoid defining
consistency as “the data is correct” without naming constraints and actors.
:::

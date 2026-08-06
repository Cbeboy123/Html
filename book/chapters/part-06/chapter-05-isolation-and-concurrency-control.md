## 6.5 - Isolation and Concurrency Control {#chapter-06-05}

Isolation controls which interleavings concurrent transactions can observe. The
names “read committed,” “repeatable read,” and “serializable” do not map
identically across every product; reason from prohibited anomalies.

Common anomalies include dirty reads, non-repeatable reads, phantoms, lost
updates, and write skew. **Serializability** means committed outcomes are
equivalent to some serial transaction order, not that transactions physically
run one at a time.

~~~mermaid
sequenceDiagram
    participant T1 as Transaction T1
    participant Row as Logical row
    participant T2 as Transaction T2
    T1->>Row: Create version V2
    T2->>Row: Read snapshot selecting V1
    T1->>Row: Commit V2
    T2->>Row: Later snapshot may select V2
    Note over T1,T2: Visibility depends on snapshot and engine rules
~~~

*Diagram key: solid arrows are reads/writes against logical row versions; the
note states the MVCC visibility rule without assuming one vendor’s format.*

**MVCC** keeps multiple row versions so readers can often use a snapshot without
blocking writers. Versions still require cleanup, and long transactions can
retain old versions. MVCC does not by itself prevent every write conflict or
write skew.

Locking can protect rows, keys, ranges, or predicates. Deadlock detection aborts
a participant so work can retry; deterministic lock order reduces cycles.
Optimistic control validates that observed state has not changed before commit.

::: {.gotcha}
**Gotcha**

“Serializable” and “snapshot isolation” are not synonyms. Snapshot isolation can
allow write skew unless the database adds stronger checks.
:::

<!-- FILE: book/chapters/part-06/chapter-01-from-durable-bytes-to-a-database.md -->
## 6.1 - From Durable Bytes to a Database {#chapter-06-01}

A database acknowledges a transaction, then the machine loses power. Recovery
must distinguish committed work from incomplete page updates.

Storage engines organize data into pages and keep frequently used pages in a
**buffer pool**. Modifying a cached page does not necessarily write that page
immediately. A **write-ahead log** (WAL) records recovery information before the
corresponding data-page changes are allowed to reach durable storage under the
engine’s protocol.

~~~mermaid
flowchart LR
    tx[Transaction changes] --> log[Append WAL records]
    log ==> durable[(Durable WAL)]
    tx --> dirty[Dirty buffer-pool pages]
    dirty -.->|later flush| pages[(Data files)]
    checkpoint[Checkpoint metadata] --> durable
    crash{Crash} --> recovery[Recovery scans log]
    durable --> recovery
    pages --> recovery
    recovery --> consistent[(Consistent database state)]
~~~

*Diagram key: rectangles are active engine stages; cylinders are persistent
state; dashed arrow is deferred page flush; thick arrow is required WAL
durability; diamond is a crash event.*

A **checkpoint** records a recovery boundary and coordinates background work so
recovery need not begin at the start of history. It does not necessarily mean
every cached page is written at one instant. Exact checkpoint algorithms vary.

Recovery commonly re-establishes effects that should be present and removes or
ignores effects of incomplete transactions. The precise redo/undo protocol is
engine-specific. The durable principle is ordered logging plus an idempotent
recovery procedure.

Torn writes, corrupted storage, lost acknowledgments, and misconfigured
durability expose assumptions beneath the engine. Replication is not a backup:
it can faithfully copy deletion or corruption.

::: {.interview-tip}
**Interview Tip**

Explain why WAL permits random page updates to be flushed later while preserving
recovery. Do not say “commit writes every changed table page to disk.”
:::

<!-- FILE: book/chapters/part-06/chapter-02-the-relational-model.md -->
## 6.2 - The Relational Model {#chapter-06-02}

The relational model represents information as relations of tuples over defined
attributes. SQL products implement this model with practical extensions and
multiset behavior, so relational theory and SQL syntax are related but not
identical.

A **candidate key** uniquely identifies a tuple. A primary key is the candidate
chosen as the main identifier. A foreign key constrains values to reference an
allowed key, preserving referential integrity. A unique constraint expresses a
business invariant rather than merely accelerating lookup.

`NULL` represents missing/unknown/not-applicable information under SQL’s
three-valued logic. Comparisons involving NULL do not behave like comparisons
with an ordinary value; use the language’s explicit null predicates. Products
can differ in details such as uniqueness and null handling.

Constraints keep correctness close to shared data. Application validation
improves user feedback, but concurrent writers can both pass a prior read.
Database constraints arbitrate at the write boundary.

Logical design describes facts and relationships. Physical design chooses
indexes, partitioning, storage layout, and access paths. One logical model can
support several physical designs without changing its meaning.

::: {.gotcha}
**Gotcha**

Surrogate keys provide stable identity but do not replace natural uniqueness
constraints. Without the latter, duplicate business facts remain possible.
:::

<!-- FILE: book/chapters/part-06/chapter-03-normalization-and-deliberate-denormalization.md -->
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

<!-- FILE: book/chapters/part-06/chapter-04-transactions-and-acid.md -->
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

<!-- FILE: book/chapters/part-06/chapter-05-isolation-and-concurrency-control.md -->
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

<!-- FILE: book/chapters/part-06/chapter-06-indexes.md -->
## 6.6 - Indexes {#chapter-06-06}

An index is a maintained access structure that trades write/storage work for
faster selected lookups. It does not make every query faster.

~~~mermaid
flowchart TB
    root[Root: separator keys] --> internal1[Internal node]
    root --> internal2[Internal node]
    internal1 --> leaf1[Leaf: ordered key entries]
    internal1 --> leaf2[Leaf: ordered key entries]
    internal2 --> leaf3[Leaf: ordered key entries]
    leaf1 <--> leaf2
    leaf2 <--> leaf3
    leaf1 -.-> rows[(Rows or row identifiers)]
~~~

*Diagram key: rectangles are B+tree nodes; cylinder is table data; solid arrows
descend the tree; bidirectional leaf links support range traversal; dashed arrow
shows row lookup when data is not covered.*

A B+tree keeps search keys in a balanced tree and data references or values at
the leaves. Linked/ordered leaves make range scans efficient. Exact page layout,
fan-out, and concurrency protocol are implementation-specific.

Composite index order matters. A query can efficiently use prefixes and ranges
according to engine rules. A **covering index** contains everything needed by a
query, avoiding additional table lookup. It increases storage and write
amplification.

Hash indexes suit equality access but not ordinary ordered ranges. Bitmap and
specialized indexes fit other workloads; support varies.

“Clustered index” terminology differs among products. Some organize table data
by a chosen key; others use heap/table structures plus secondary indexes. Verify
the engine rather than universalizing one product.

Low selectivity, stale statistics, functions on indexed columns, type
conversion, and a large result set can make a scan cheaper than an index path.

<!-- FILE: book/chapters/part-06/chapter-07-queries-and-execution-plans.md -->
## 6.7 - Queries and Execution Plans {#chapter-06-07}

SQL states a desired result. The optimizer chooses a physical plan using
available access paths, transformations, and cardinality estimates.

~~~mermaid
flowchart LR
    sql[SQL text + parameters] --> parse[Parse and bind]
    parse --> rewrite[Logical rewrite]
    rewrite --> estimate[Estimate cardinalities and cost]
    estimate --> plan[Choose physical operators]
    plan --> scan[Scan or seek]
    scan --> join[Join]
    join --> aggregate[Sort or aggregate]
    aggregate --> result([Result rows])
~~~

*Diagram key: rectangles are optimizer/execution stages; rounded box is the
returned result; solid arrows follow planning then execution order.*

Physical operators include scans, index access, nested-loop/hash/merge joins,
sorts, filters, and aggregation. Each has input-shape requirements and memory/I/O
tradeoffs. A nested loop is not inherently bad; it is excellent when the outer
input is small and inner lookup is cheap.

Cardinality estimation predicts row counts. Correlated columns, skew, stale
statistics, parameter-sensitive distributions, and expressions can cause large
errors. Bad estimates lead to wrong join order, memory grants, and access paths.

An estimated plan shows optimizer assumptions; an actual execution adds observed
row and timing information, with measurement overhead. Compare estimated and
actual cardinalities early. “Cost percentages” are internal model estimates, not
wall-clock measurements.

Spills indicate an operator exceeded its memory allocation and used temporary
storage. Blocking, lock waits, I/O, and client consumption may dominate even
when the plan shape is reasonable.

::: {.interview-tip}
**Interview Tip**

Start with rows and estimates, then operator choice and waits. “Add an index” is
not a diagnosis.
:::

<!-- FILE: book/chapters/part-06/chapter-08-scaling-and-protecting-data.md -->
## 6.8 - Scaling and Protecting Data {#chapter-06-08}

**Partitioning** divides data into managed subsets. It can prune work and improve
maintenance, but a query that ignores the partition key may touch every subset.

**Replication** copies data to other nodes for availability, locality, or read
capacity. Replication lag makes replicas stale. Synchronous acknowledgment can
improve durability while increasing latency or reducing availability during
failure; exact guarantees depend on the protocol and configuration.

**Sharding** distributes ownership of different data across nodes. The shard key
determines routing and hotspot risk. Cross-shard joins, uniqueness, transactions,
and rebalancing become distributed problems.

Failover must prevent split brain and stale-primary writes. Promotion also
changes connection routing and may lose acknowledged work if the durability
contract allowed lag. Test the actual recovery procedure.

Backups protect against failures replication does not: accidental deletion,
logical corruption, or compromise. A backup is useful only if it can be
restored. Define **RPO** (maximum tolerable data-loss interval) and **RTO**
(target time to restore service) as business objectives, then test restore time
and recovered consistency.

::: {.interview-tip}
**Interview Tip**

For each scaling mechanism, name the new coordination cost. Partitioning,
replication, and sharding solve different problems.
:::

<!-- FILE: book/chapters/part-06/chapter-09-choosing-a-data-model.md -->
## 6.9 - Choosing a Data Model {#chapter-06-09}

Choose a data model from invariants, access patterns, scale, failure behavior,
and operational capability—not from category labels.

| Model | Natural strength | Tradeoff to examine |
|---|---|---|
| Relational | Constraints, joins, transactions, flexible querying | Horizontal distribution and schema-change operations |
| Key-value | Direct lookup by key | Limited server-side relationships/querying |
| Document | Aggregate-shaped records and flexible fields | Cross-document invariants and duplication |
| Wide-column | Partitioned sparse records at large scale | Key-driven access and hotspot design |
| Graph | Traversing relationships | Distribution and broad analytical scans |
| Search index | Text relevance and inverted lookup | Usually a derived, eventually updated representation |

“NoSQL” is a broad historical label, not one consistency or storage model.
Products in the same category can provide different transactions, indexes, and
replication guarantees.

Consistency requirements belong to operations and invariants. A product may
offer linearizable access for one operation and eventual propagation for
another. Read the guarantee’s scope.

Polyglot persistence is justified when distinct data needs outweigh extra
operations, security, backup, expertise, and cross-system consistency. A search
index or cache should have a rebuild/reconciliation path from an authoritative
source.

::: {.interview-tip}
**Interview Tip**

State the invariant first, then the access path and failure model. “Use NoSQL for
scale” is not a decision.
:::

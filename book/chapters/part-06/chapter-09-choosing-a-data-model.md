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

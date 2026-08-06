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

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

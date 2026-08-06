## 1.7 — Complexity Without Coding Puzzles {#chapter-01-07}

Two implementations are both “linear,” but one is much faster. Big-O notation
did not fail; it answered a narrower question than the engineer asked.

**Asymptotic complexity** describes how resource use grows with input size while
ignoring constant factors and lower-order terms. It helps reject approaches
whose growth will dominate at scale. It is not a latency prediction.

| Growth | Intuition | Common risk |
|---|---|---|
| `O(1)` | Bounded independently of input size | The constant may include remote I/O or contention |
| `O(log n)` | Repeatedly reduces the remaining search space | Random access and comparisons still cost |
| `O(n)` | Work grows with every item | Allocation and data transfer can dominate |
| `O(n log n)` | Common comparison-sorting shape | Memory and comparator behavior matter |
| `O(n²)` | Many pairs of items interact | Small tests can hide the growth |

Space complexity matters alongside time. Retaining a complete result can exhaust
memory even when producing each item is cheap. Streaming can bound memory, but
introduces partial results, backpressure, and resource-lifetime concerns.

The input model must be stated. Hash-table access is commonly expected constant
time under a suitable hash function and controlled load, but collisions and
resizing matter. A database index lookup cost does not include transferring a
large result set. A cached call may be cheap on a hit and expensive on a miss.

Constant factors are architectural facts:

- contiguous arrays often have better locality than pointer-heavy structures;
- one allocation per item increases allocator and collector work;
- vectorized or batched operations reduce repeated overhead;
- crossing a process or network boundary changes the cost model;
- locks and shared resources add waiting absent from single-thread analysis.

::: {.scenario}
**Real-World Scenario**

Imagine replacing one database query with a query inside a loop. The application
loop is `O(n)`, but each iteration crosses the network and performs database
work. “N remote round trips” is the useful diagnosis, not merely “linear.”
:::

Measure realistic sizes and distributions. Report median and tail latency,
throughput, allocation, and saturation—not only an average. Confirm that the
load generator is not the bottleneck.

::: {.interview-tip}
**Interview Tip**

Give the growth rate, state its assumptions, and then discuss locality,
allocation, I/O, and expected data size. That is performance reasoning rather
than notation recital.
:::


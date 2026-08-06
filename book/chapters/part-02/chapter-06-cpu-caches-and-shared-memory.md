## 2.6 - CPU Caches and Shared Memory {#chapter-02-06}

Two threads update different counters, yet throughput collapses. The variables
are logically independent but occupy the same cache line.

CPU caches move data in **cache lines**: fixed-size blocks whose exact size is
architecture-specific. **Spatial locality** means nearby data is likely to be
used; **temporal locality** means recently used data is likely to be reused.

~~~mermaid
flowchart TB
    subgraph coreA[Core A]
      a[L1 cache: line X]
    end
    subgraph coreB[Core B]
      b[L1 cache: line X]
    end
    shared[Coherence mechanism]
    ram[(Main memory)]
    a <--> shared
    b <--> shared
    shared <--> ram
    t1[Thread A updates field 1] --> a
    t2[Thread B updates field 2] --> b
~~~

*Diagram key: rectangles are cores, caches, threads, or coherence work;
cylinder is main memory; bidirectional arrows show coherence traffic; solid
one-way arrows show each thread’s access.*

**Cache coherence** keeps cores from indefinitely using incompatible cached
copies of the same memory location. It does not make a data race safe or impose
all ordering a programming language requires.

**False sharing** occurs when threads modify different data that happens to
share a cache line. Ownership repeatedly moves between cores even though the
fields are independent. Padding or partitioning can help, but should follow
measurement because layout and line size are implementation details.

Other locality failures include linked structures, large working sets, and
multiple threads streaming through memory until bandwidth saturates. A low CPU
instruction count can still be memory-bound.

::: {.interview-tip}
**Interview Tip**

Separate coherence from consistency. Coherent hardware is necessary support,
but language-level visibility and ordering still require synchronization.
:::

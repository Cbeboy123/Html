## 2.4 - Garbage Collection from First Principles {#chapter-02-04}

Garbage collection does not remove the need to reason about memory. It automates
reclamation of unreachable objects; it cannot decide that a reachable but
useless cache entry should disappear.

A **garbage collector** identifies objects reachable from roots such as active
thread state and runtime-managed references. Unreachable objects can be
reclaimed. Tracing collectors commonly mark reachable objects and then sweep,
compact, or copy regions. Reference counting is another approach, but cycles
need special handling.

The **generational hypothesis** is the observed tendency in many workloads for
many objects to die young. Generational collectors exploit this by collecting
younger regions more frequently and tracking references from older regions.
This is common, not a law of every collector or workload.

Collector tradeoffs include:

| Goal | Typical pressure |
|---|---|
| High throughput | More or longer collector work may be acceptable |
| Short pauses | More concurrent work, barriers, metadata, or headroom |
| Small footprint | Less space available for copying or concurrent progress |
| Predictability | May give up peak throughput or require stricter allocation control |

**Stop-the-world** means application threads are paused for a collector phase.
Concurrent collectors still require some coordination pauses; “concurrent” does
not mean pause-free. Write and read barriers maintain collector invariants while
the application changes references.

Diagnose with allocation rate, live-set trend, pause distribution, collector CPU
time, promotion/evacuation failures, and memory headroom. Exact log fields and
tuning controls are runtime- and version-specific.

::: {.interview-tip}
**Interview Tip**

Start from reachability and workload goals. Tuning a heap flag before finding
allocation and retention causes is configuration roulette.
:::

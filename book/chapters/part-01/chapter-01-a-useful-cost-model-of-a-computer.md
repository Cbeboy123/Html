## 1.1 — A Useful Cost Model of a Computer {#chapter-01-01}

Imagine a request that performs little business logic yet remains slow. The code
may wait on memory, storage, a lock, or a network response. A useful cost model
starts by asking where the work happens and what the processor must wait for.

A **CPU** (the component that executes machine instructions) works on values held
in registers. Registers are tiny storage locations inside a CPU core. Data that
is not already there must move through one or more cache levels from main memory,
or arrive from storage or another machine.

~~~mermaid
flowchart LR
    core[CPU core] -->|load or store| l1[Private L1 cache]
    l1 -->|cache miss| l2[Private or local L2]
    l2 -->|cache miss| l3[Shared last-level cache]
    l3 -->|cache miss| ram[(Main memory)]
    ram -.->|file-backed page| disk[(Persistent storage)]
    core -.->|remote request| network([Another machine])
~~~

*Diagram key: rectangle = active hardware component; cylinder = retained data;
rounded box = independently operated system. Solid arrows show direct memory
traffic; dashed arrows show slower work outside the immediate CPU/cache path.*

The hierarchy is not merely “small and fast” versus “large and slow.” It creates
behavioral consequences:

- A cache hit avoids fetching the same data from a lower level.
- Sequential access often helps hardware and operating systems predict what will
  be needed next.
- Random pointer chasing can defeat locality even when the algorithm has a good
  asymptotic complexity.
- Persistent storage retains data across process or machine restarts; CPU caches
  and ordinary RAM do not provide that guarantee.
- A remote call introduces serialization, queues, network loss, and another
  machine’s load. Its cost is not a fixed constant.

**Latency** means time for one operation to finish. **Throughput** means completed
work per unit of time. They interact but are not interchangeable: batching may
raise throughput while making an individual item wait longer. Concurrency can
hide waiting until the shared resource saturates, at which point queues grow and
tail latency rises sharply.

::: {.scenario}
**Real-World Scenario**

Imagine an endpoint that reads thousands of rows and constructs a large object
graph. Adding threads may make it worse: the threads compete for memory
bandwidth, allocate more objects, and put pressure on garbage collection. A
profile showing cache misses, allocation, and database wait time is more useful
than guessing that the CPU is “too slow.”
:::

Measurement must match the suspected boundary. CPU profiles expose executed
work; allocation profiles expose object churn; operating-system counters expose
faults and I/O; distributed traces expose time across services. A benchmark is
evidence only for its workload, hardware, data shape, and runtime configuration.

::: {.interview-tip}
**Interview Tip**

A senior answer names the resource, distinguishes service time from queueing
time, and proposes a measurement. “Memory is faster than disk” is only the first
sentence.
:::


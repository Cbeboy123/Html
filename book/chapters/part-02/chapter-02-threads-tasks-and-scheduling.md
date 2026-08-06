## 2.2 - Threads, Tasks, and Scheduling {#chapter-02-02}

An application has runnable work, but the CPU count is finite. A **thread** is an
execution sequence with its own call stack and register state; threads within a
process commonly share the process’s heap and open resources.

**Concurrency** means multiple tasks can make progress during overlapping time.
**Parallelism** means tasks execute at the same instant on different processing
units. One core can provide concurrency by switching among threads without
providing parallel execution.

The scheduler selects runnable work. A **context switch** saves one execution
context and restores another. Switching has direct overhead and can disturb
cache locality. Yet avoiding all switches is not the goal: a blocked thread must
yield so useful work can run.

Threads move among conceptual states:

~~~mermaid
stateDiagram-v2
    [*] --> Runnable
    Runnable --> Running: scheduled
    Running --> Runnable: preempted or yields
    Running --> Waiting: blocks
    Waiting --> Runnable: event completes
    Running --> [*]: exits
~~~

*Diagram key: solid arrows are scheduler or lifecycle transitions; state boxes
represent execution eligibility rather than a vendor-specific thread API.*

CPU-bound work is limited by compute capacity; I/O-bound work often spends time
waiting. Adding threads can hide I/O waits, but excessive runnable work creates
contention, switching, larger queues, and memory use. Thread pools bound resource
use only if their queues and submission policies are also bounded.

Scheduling fairness and priority behavior are implementation-specific. A higher
priority is not a completion guarantee, and long non-preemptible or lock-holding
work can delay other tasks.

Production diagnosis separates runnable saturation from blocked waiting. Inspect
CPU utilization, run-queue pressure, thread states, lock waits, and I/O latency
together.

::: {.interview-tip}
**Interview Tip**

Relate the thread count to workload and bottleneck. “More threads means more
parallelism” ignores core count, blocking, contention, and queueing.
:::

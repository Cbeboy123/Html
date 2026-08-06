## 2.8 - Synchronization and Liveness {#chapter-02-08}

Correct synchronization protects both safety and progress. A result can be free
of corrupted data yet still hang forever.

A **mutex** provides mutual exclusion around a critical section. A **semaphore**
tracks permits and can bound concurrent access to a resource. A **condition
variable** lets threads wait for a state predicate while releasing a lock. A
read/write lock distinguishes readers from writers, but helps only under a
suitable workload and fairness policy.

Always wait on the predicate, not on the notification alone. Wakeups may be
spurious or another thread may consume the condition first; exact APIs vary, but
the predicate-loop principle is durable.

| Failure | Meaning | Typical evidence |
|---|---|---|
| Deadlock | Participants wait in a cycle that cannot resolve | Stable wait-for cycle, no progress |
| Livelock | Participants keep reacting but make no useful progress | Activity without completions |
| Starvation | One participant repeatedly loses access | Extreme wait distribution |
| Priority inversion | High-priority work waits on lower-priority owner | Scheduler and lock-owner evidence |

Deadlock prevention techniques include a global lock order, avoiding calls into
unknown code while holding locks, reducing lock scope, and using timeouts only
as recovery—not as proof of correctness. A timeout breaks waiting but may leave
partial work requiring compensation.

Lock-free means system-wide progress under specified conditions; wait-free means
each operation completes within a bounded number of its own steps. Neither means
contention-free or automatically faster.

::: {.interview-tip}
**Interview Tip**

Name the protected invariant and the progress requirement. Picking “mutex versus
semaphore” before stating those is tool-first reasoning.
:::

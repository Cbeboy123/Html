<!-- FILE: book/chapters/part-02/chapter-01-programs-become-processes.md -->
## 2.1 - Programs Become Processes {#chapter-02-01}

A program on disk is passive. A **process** (a running program with an isolated
virtual address space and operating-system-managed resources) is what the
operating system schedules and protects.

Applications normally execute in **user mode**, where privileged hardware
operations are restricted. The kernel runs in a privileged mode and exposes
**system calls**: controlled entry points for operations such as opening a file,
creating a process, mapping memory, or using a socket. A system call crosses a
protection boundary; it is not identical to an ordinary function call.

A process owns or refers to resources including virtual-memory mappings, open
file descriptors, credentials, signal dispositions, and an environment.
Processes can share resources deliberately, but isolation is the default
reasoning model. A crash usually destroys the process’s volatile state while
leaving kernel-managed and external effects subject to their own lifecycle.

~~~mermaid
flowchart TB
    app[Application in user mode] -->|system call| kernel[Kernel]
    kernel --> scheduler[Scheduler]
    kernel --> memory[Virtual memory manager]
    kernel --> io[I/O subsystem]
    io --> device([Device or network])
~~~

*Diagram key: rectangles are active software components; the rounded box is an
external device or network. Solid arrows are control transfers or requests.*

A **file descriptor** is a process-local handle referring to a kernel-managed
open resource. It may represent a regular file, pipe, socket, or device.
Descriptors can leak just as heap objects can; exhaustion appears as failed
opens or connections even when memory is available.

Creation and replacement semantics vary across operating systems. On Unix-like
systems, process creation and program replacement are separate concepts, and
inherited descriptors require careful close-on-exec policy. Treat exact APIs as
platform-specific.

::: {.interview-tip}
**Interview Tip**

Explain protection and ownership, not merely “a process is a program in
execution.” Mention system calls, virtual address spaces, descriptors, and what
must be cleaned up on failure.
:::

<!-- FILE: book/chapters/part-02/chapter-02-threads-tasks-and-scheduling.md -->
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

<!-- FILE: book/chapters/part-02/chapter-03-stack-heap-and-allocation.md -->
## 2.3 - Stack, Heap, and Allocation {#chapter-02-03}

A recursive call fails with stack exhaustion while the machine still has free
memory. Elsewhere, a service retains millions of reachable objects and exhausts
its heap. Both are memory failures, but their mechanisms differ.

A **call stack** records active calls, including return information and local
state chosen by the compiler/runtime. Each thread normally has a stack. A
**heap** is a region used for dynamically allocated data whose lifetime is not
tied to one active call. Exact placement of a variable is an optimization detail
in many runtimes; “local means stack” is not a universal rule.

An allocator finds space, records enough metadata to reclaim it, and manages
alignment. Allocation can be very cheap on a fast path, but the full cost
includes initialization, cache effects, later reclamation, and possible
fragmentation.

**Internal fragmentation** wastes space inside allocated blocks; **external
fragmentation** leaves free space split into pieces that may not satisfy a large
request. Moving garbage collectors can compact live objects, while manual or
non-moving allocators use other strategies.

Object retention is not automatically a leak. A cache intentionally retains
objects, but becomes leak-like when its growth is unbounded or its eviction
policy does not match demand. Native buffers, memory mappings, thread stacks,
and runtime metadata can consume memory outside a managed heap.

Useful evidence includes allocation rate, live-set size after collection,
retention paths, resident memory, page faults, and native-memory accounting.

::: {.gotcha}
**Gotcha**

An out-of-memory error does not prove the Java or managed heap is full. Process
limits, native allocation, mappings, container limits, or address-space
fragmentation may be the actual boundary.
:::

::: {.interview-tip}
**Interview Tip**

Discuss lifetime and ownership. The senior question is not “stack or heap?” but
which resource grows, why it remains live, and which measurement proves it.
:::

<!-- FILE: book/chapters/part-02/chapter-04-garbage-collection-from-first-principles.md -->
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

<!-- FILE: book/chapters/part-02/chapter-05-virtual-memory.md -->
## 2.5 - Virtual Memory {#chapter-02-05}

Two processes both use the same numeric address without corrupting each other.
**Virtual memory** gives each process an address space that the operating system
and hardware translate to physical memory or other backing.

~~~mermaid
flowchart LR
    cpu[CPU issues virtual address] --> tlb{TLB entry?}
    tlb -->|hit| physical[Physical frame]
    tlb -->|miss| walk[Page-table walk]
    walk --> present{Page present?}
    present -->|yes| physical
    present -->|no| fault[Page fault handler]
    fault --> backing[(File or swap backing)]
    backing -->|load page| physical
~~~

*Diagram key: rectangles are active translation/handling steps; diamonds are
conditions; the cylinder is persistent backing. Solid arrows show address
translation and page loading.*

A **page** is a fixed-size virtual-memory unit; a **frame** is the corresponding
physical-memory unit. Page tables store mappings and permissions. A
**translation lookaside buffer** (TLB) caches recent translations.

A page fault is not inherently an error. It can allocate a zero-filled page,
load file-backed data, implement copy-on-write, or signal invalid access. A
major fault requiring storage work is much costlier than a mapping resolved in
memory, but exact terminology and counters vary by OS.

Paging enables isolation, sparse address spaces, shared libraries, memory-mapped
files, and controlled overcommit. It also creates failure modes: memory pressure,
thrashing, unexpected copy-on-write costs, and out-of-memory termination.
**Thrashing** is repeated movement of working data because active demand exceeds
available memory.

Segmentation historically used variable-sized logical regions; modern
general-purpose systems rely primarily on paging, though architectural details
vary.

::: {.interview-tip}
**Interview Tip**

Distinguish virtual address space, resident physical memory, and durable backing.
“The process allocated 8 GB” does not by itself say 8 GB is resident.
:::

<!-- FILE: book/chapters/part-02/chapter-06-cpu-caches-and-shared-memory.md -->
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

<!-- FILE: book/chapters/part-02/chapter-07-the-memory-model.md -->
## 2.7 - The Memory Model {#chapter-02-07}

One thread sets a “ready” flag after constructing an object; another sees the
flag but stale object fields. Source order alone does not establish safe
publication.

A **memory model** defines which values concurrent operations may observe and
which reorderings are permitted. Compilers and processors reorder work when
single-thread behavior is preserved, but another thread can expose the
difference unless the program establishes ordering.

A **data race** generally means conflicting accesses to shared memory without
the synchronization required by the language. Exact consequences vary: some
languages sharply restrict program meaning, while managed runtimes may define a
broader set of outcomes.

**Happens-before** is a formal ordering relation used to reason about visibility.
If action A happens-before action B, effects required by the model become
visible to B. Program order, lock release/acquisition, thread lifecycle
operations, and atomic/volatile-style operations can create edges, depending on
the language.

~~~mermaid
flowchart LR
    write[Write object fields] --> publish[Release or synchronized publish]
    publish ==> observe[Acquire or synchronized observe]
    observe --> read[Read initialized fields]
~~~

*Diagram key: rectangles are memory actions; the thick arrow is the
synchronization edge that carries ordering/visibility, not a data copy.*

An **atomic operation** appears indivisible at the model’s stated scope.
Atomicity alone may not protect a multi-step invariant. A compare-and-set loop
can update one value safely while still suffering contention, starvation, or
the ABA problem in suitable algorithms.

::: {.gotcha}
**Gotcha**

`volatile`, atomics, and fences have language-specific guarantees. Do not copy a
rule from Java into C++, JavaScript, or a database transaction.
:::

::: {.interview-tip}
**Interview Tip**

Draw the publication edge. “The writer ran first” is a timing observation;
happens-before is the guarantee.
:::

<!-- FILE: book/chapters/part-02/chapter-08-synchronization-and-liveness.md -->
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

<!-- FILE: book/chapters/part-02/chapter-09-files-i-o-and-durability.md -->
## 2.9 - Files, I/O, and Durability {#chapter-02-09}

A successful write call does not always mean bytes survive power loss. Several
buffers and devices may sit between application memory and durable media.

A **file system** maps names and directories to stored data and metadata. The
operating system’s **page cache** keeps file-backed pages in memory. Buffered
writes may return after copying data into memory, with persistence occurring
later. A flush/synchronization operation requests stronger ordering or
durability, but exact guarantees depend on the OS, file system, device, and
application protocol.

~~~mermaid
flowchart LR
    app[Application buffer] -->|write| cache[OS page cache]
    cache -.->|write-back| device[Device controller]
    device ==> media[(Persistent media)]
    app -->|sync request| cache
~~~

*Diagram key: rectangles are active buffering/I/O stages; cylinder is persistent
media; dashed arrow is deferred write-back; thick arrow is the persistence path.*

**Blocking I/O** can suspend the calling thread until progress or completion.
Non-blocking I/O returns when an operation would wait. Readiness APIs report
which descriptors may make progress; asynchronous completion APIs report later
completion. Names and exact behavior vary by platform.

Files are byte sequences, while record boundaries belong to a format. Partial
reads and writes are normal for many APIs. Correct code loops until the intended
amount is processed or a terminal condition occurs.

Crash-safe updates often require a protocol: write new data, make required bytes
durable, atomically switch a reference where supported, and make directory
metadata durable when the platform requires it. “Rename is atomic” is
insufficient without defining scope, file system, and durability.

::: {.interview-tip}
**Interview Tip**

Separate visibility from durability. Another process reading new bytes does not
prove those bytes will survive a crash.
:::

<!-- FILE: book/chapters/part-02/chapter-10-practical-linux-and-isolation.md -->
## 2.10 - Practical Linux and Isolation {#chapter-02-10}

Production diagnosis improves when each command answers a question. Running a
large command checklist without a hypothesis produces snapshots, not evidence.

| Question | Useful Linux surface |
|---|---|
| Which processes or threads consume CPU? | `ps`, `top`, scheduler/proc counters |
| Which files or sockets are open? | `lsof`, `/proc/<pid>/fd` |
| Which system calls block or fail? | `strace` where permitted |
| What memory is mapped or resident? | `/proc/<pid>/maps`, `smaps`, process counters |
| Which signal ended the process? | supervisor/kernel logs and exit status |

`/proc` is a kernel-provided view whose fields and availability depend on the
Linux version and permissions. `strace` observes the system-call boundary; it
can alter timing and adds overhead, so use it deliberately.

A **signal** is an asynchronous notification delivered under OS rules. Graceful
shutdown code must stop accepting work, drain or cancel bounded in-flight work,
flush state that must be durable, and exit before the supervisor’s deadline.
Not every termination can be intercepted.

Containers build isolation from kernel mechanisms. **Namespaces** give processes
separate views of resources such as process IDs, mounts, or networking.
**cgroups** account for and limit resources. A container shares the host kernel;
it is not the same isolation boundary as a virtual machine with a separate
guest kernel.

Limits are part of behavior. CPU quotas can cause throttling; memory limits can
trigger reclamation or termination; descriptor and process limits can reject
new work. Application metrics may look healthy if they omit the cgroup and host
boundary.

::: {.scenario}
**Real-World Scenario**

Imagine a service showing low average CPU but periodic latency spikes. Cgroup
throttling counters align with the spikes. Adding application threads would
increase contention; the useful next question concerns quota and burst shape.
:::

::: {.interview-tip}
**Interview Tip**

State the hypothesis before the command: “I suspect descriptor exhaustion, so I
will compare open descriptors with the process limit and identify their types.”
:::

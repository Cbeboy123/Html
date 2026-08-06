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

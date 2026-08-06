## 13.2 - Concurrency, Visibility, and Safe State {#chapter-13-02}

Concurrency problems are easier when you separate three questions:

1. **Atomicity:** can another thread observe a half-finished operation?
2. **Visibility:** when must one thread see another thread's writes?
3. **Ordering:** which operation is allowed to appear first?

A lock, atomic variable, channel, immutable message, or transaction answers some combination of these questions. “Thread safe” is too vague unless the protected invariant is named.

### Why `count = count + 1` can lose work

The statement looks like one action but normally contains a read, calculation, and write:

~~~text
Thread A reads count = 10
Thread B reads count = 10
Thread A writes 11
Thread B writes 11
~~~

Two increments produced one result. Making the variable visible does not make the read-modify-write sequence atomic. Use an atomic increment when the invariant is one counter. Use a lock or a higher-level state owner when several values must change together.

### Safe publication

Suppose one thread constructs an object and then sets `ready = true`. Another thread waits for `ready` and reads the object. Source order alone is not the guarantee. The program needs a **happens-before** edge supplied by the language: for example, lock release followed by acquisition, a suitable volatile/release-acquire pair, thread start/join, or a safe concurrent collection.

~~~mermaid
flowchart LR
    build[Build complete object] --> release[Release or lock exit]
    release ==> acquire[Acquire or lock enter]
    acquire --> read[Read initialized state]
~~~

*Diagram key: rectangles are program actions; the thick arrow is the synchronization edge that carries ordering and visibility.*

The exact primitives differ by language. Do not move Java rules into C++, Go, Rust, JavaScript, or a database. The durable method is to find the documented synchronization edge.

### Choose ownership before choosing a primitive

| State shape | Usually clear approach |
|---|---|
| One independent numeric value | Atomic operation |
| Several values with one invariant | Lock around the whole transition |
| Work passed between components | Bounded channel or queue |
| Read-mostly immutable configuration | Immutable snapshot and atomic replacement |
| Partitioned entities | Single owner per key or partition |
| Durable business state | Database constraint and transaction |

Atomics can avoid blocking but are not automatically faster. Under heavy contention, many threads repeatedly fail compare-and-set operations and generate cache-coherence traffic. A short lock or single owner can be simpler and faster.

::: {.fact}
**Surprising Fact - Independent fields can still fight**

Two threads may update different counters and still slow each other if the counters share one CPU cache line. The cache-coherence protocol moves ownership of the whole line between cores. This is **false sharing**. Measure it before adding padding because object layout and cache-line size are implementation details.
:::

### Safety is not progress

A program may protect data and still stop making progress:

- **Deadlock:** participants wait in a cycle.
- **Livelock:** participants keep reacting but complete nothing.
- **Starvation:** one participant repeatedly loses access.
- **Priority inversion:** urgent work waits for a resource held by less urgent work.

Prevent deadlock with a global lock order, small critical sections, and no calls into unknown code while holding a lock. A timeout can end waiting, but it does not repair a partly completed action.

### Cancellation and structured lifetime

Concurrency also creates resource-lifetime problems. When a parent request is cancelled, child work should stop where safe, release connections, and avoid publishing results no caller can use. A task must not outlive the resources it borrows. Bounded, structured task lifetimes are easier to operate than detached background work.

Use this review checklist:

1. What state is shared?
2. Who owns each invariant?
3. Which operation is the serialization point?
4. Which synchronization edge provides visibility?
5. What is the maximum waiting time and queue size?
6. What happens during cancellation or process exit?
7. Which profile, lock trace, or counter would prove contention?

::: {.interview-tip}
**Staff-Level Answer**

Draw the state transition and the happens-before edge. Then discuss contention, cancellation, and measurement. Naming `volatile`, a mutex, or an atomic class without the invariant is tool-first reasoning.
:::


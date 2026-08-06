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

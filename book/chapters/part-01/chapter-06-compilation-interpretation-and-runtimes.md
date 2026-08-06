## 1.6 — Compilation, Interpretation, and Runtimes {#chapter-01-06}

A service is “compiled,” yet it becomes faster after warm-up. That sounds
contradictory only if compilation is treated as a single step.

A **compiler** translates one program representation into another. An
**interpreter** executes a representation by inspecting it at runtime. A
**runtime** is the machinery supporting a running program: loading, allocation,
exceptions, libraries, scheduling integration, and often garbage collection.

~~~mermaid
flowchart LR
    source[Source code] --> frontend[Parse and analyze]
    frontend --> ir[Intermediate form]
    ir --> aot[Ahead-of-time compiler]
    ir -.-> vm[Managed runtime]
    vm --> jit[Just-in-time compiler]
    aot --> native[Machine code]
    jit --> native
    native --> os[OS and hardware]
~~~

*Diagram key: rectangles are transformation or execution stages. Solid arrows
show an ahead-of-time path; the dashed arrow shows loading into an independently
executing managed runtime.*

**Ahead-of-time compilation** produces executable code before the program runs.
**Just-in-time compilation** compiles selected code during execution, using
observations such as which paths are hot. Interpretation can reduce startup
work, while a JIT can optimize common paths after collecting evidence. Exact
strategies vary by implementation and version.

The toolchain may include preprocessing, linking, and loading. A linker resolves
references among compiled units and libraries. A loader maps executable code
and data into a process and prepares it to run. Dynamic libraries defer some
binding until load time or execution.

Managed runtimes can speculate—for example, optimizing under the assumption
that a call site usually sees one implementation. If the assumption stops
holding, the runtime may **deoptimize**, returning to less specialized code.
This is why warm-up, workload shape, and code-cache behavior matter in managed
runtime benchmarks.

Common failures include missing native libraries, incompatible binary
interfaces, module version conflicts, excessive compilation activity, and
measuring startup as though it represented steady state. A container packages
an environment; it does not remove these dependencies.

::: {.scenario}
**Real-World Scenario**

Imagine comparing two releases with a short benchmark. One spends most of the
test loading classes and compiling hot paths. The other reuses a warmed process.
The result measures lifecycle differences, not only the code under test.
:::

::: {.interview-tip}
**Interview Tip**

Avoid the false choice “compiled or interpreted.” Describe the stages and say
when translation occurs. Java bytecode plus interpretation/JIT is one example,
not the universal definition of a runtime.
:::


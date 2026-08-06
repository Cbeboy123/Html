<!-- FILE: book/chapters/part-08/chapter-01-why-abstraction-exists.md -->
## 8.1 - Why Abstraction Exists {#chapter-08-01}

Abstraction is selective ignorance: it exposes the properties a caller needs while hiding choices the caller should not depend on. A good abstraction lowers the number of facts required to make a safe change. A bad one hides failure, cost, or ownership that the caller must understand.

Every abstraction has a contract, implementation, and leakage surface. A collection interface may hide layout but cannot hide complexity forever. An RPC stub may hide serialization but must not hide deadlines and partial failure. The right boundary follows a stable reason to change and preserves the operational facts that cross it.

Use abstractions to encode policy, not merely to rename mechanics. `PaymentAuthorizer` is useful when it states domain outcomes and idempotency; `PaymentManagerHelper` often just adds indirection. Evaluate an abstraction by the changes it localizes, invalid states it prevents, tests it enables, and performance/failure information it preserves.

::: {.gotcha}
**Gotcha**

“Implementation detail” is not a permanent label. If latency, consistency, resource ownership, or error behavior affects callers, it belongs in the contract even if the algorithm does not.
:::

<!-- FILE: book/chapters/part-08/chapter-02-the-four-oop-ideas-without-slogans.md -->
## 8.2 - The Four OOP Ideas Without Slogans {#chapter-08-02}

**Encapsulation** protects an invariant by controlling state transitions; private fields alone do not achieve it if mutable internals escape. **Abstraction** presents the essential contract. **Polymorphism** lets different implementations satisfy that contract. **Inheritance** reuses or specializes behavior through an “is-a” relationship, but also couples child behavior to parent assumptions.

Consider a rate limiter. Encapsulation keeps token counts and time updates valid. Its interface abstracts `allow(request)`. Polymorphism permits local and distributed implementations. Inheritance is optional; both implementations can compose clocks and stores instead.

Dynamic dispatch moves selection from explicit conditionals to implementations. That is valuable when variants evolve independently, but harmful when it obscures a closed, simple decision. Algebraic data types, pattern matching, modules, traits, protocols, and functions can express the same design forces in non-class-centric languages.

The goal is replaceable behavior with preserved semantics. A subtype that throws for a base operation, strengthens preconditions, or weakens postconditions is not safely substitutable even if the compiler accepts it.

::: {.interview-tip}
**Interview Tip**

Define each idea by the change or invariant it manages. Avoid explaining all four with “reuse.”
:::

<!-- FILE: book/chapters/part-08/chapter-03-composition-inheritance-and-delegation.md -->
## 8.3 - Composition, Inheritance, and Delegation {#chapter-08-03}

Composition builds behavior from owned collaborators. Delegation forwards responsibility to a collaborator. Inheritance binds a subtype to a parent contract and often to protected implementation details.

Prefer composition when capabilities vary independently, must be replaced in tests, or have distinct lifecycles. Prefer inheritance when the subtype genuinely preserves the parent’s semantics and the hierarchy is stable. Framework-required inheritance may be pragmatic; isolate it at the boundary.

Deep hierarchies create the fragile-base-class problem: a parent change affects descendants in nonlocal ways. Composition can create its own maze of tiny interfaces and forwarding layers. The criterion is not ideology but whether the design makes state, ownership, and control flow easy to trace.

Delegation is particularly useful for policy: a retrying client delegates transport, a service delegates authorization, and a repository delegates persistence. Decorators can layer cross-cutting behavior, but ordering becomes part of the contract—retry outside a transaction differs from retry inside it.

::: {.gotcha}
**Gotcha**

“Favor composition” does not mean wrap every class. Each collaborator should own a coherent decision or boundary.
:::

<!-- FILE: book/chapters/part-08/chapter-04-coupling-cohesion-and-dependency-direction.md -->
## 8.4 - Coupling, Cohesion, and Dependency Direction {#chapter-08-04}

**Cohesion** measures how strongly a module’s responsibilities belong together. **Coupling** is the knowledge or coordination one module requires from another. Good design seeks high cohesion and the lowest coupling compatible with the real domain—not zero coupling.

Coupling appears through types, data schemas, timing, deployment order, shared databases, global state, and operational fate. Two services using no shared library can still be tightly coupled if one must deploy first or answer within milliseconds for the other to function.

Dependencies should point toward stable policy. Business rules should not import HTTP frameworks or database drivers; boundary adapters translate external mechanisms into domain contracts. This is the useful core of dependency inversion.

~~~mermaid
flowchart LR
    http[HTTP adapter] --> usecase[Application policy]
    db[Database adapter] --> port[Persistence contract]
    usecase --> port
    port -.-> db
~~~

*Diagram key: rectangles = modules; solid arrows = compile-time policy dependencies; dashed arrow = runtime fulfillment by an adapter.*

Architecture tests can enforce forbidden dependencies, but naming layers is insufficient. Review data ownership, call direction, failure propagation, and deployment coupling.

<!-- FILE: book/chapters/part-08/chapter-05-solid-as-diagnostic-heuristics.md -->
## 8.5 - SOLID as Diagnostic Heuristics {#chapter-08-05}

SOLID is most useful as a set of questions, not laws.

| Heuristic | Diagnostic question |
|---|---|
| Single responsibility | Which actor or policy gives this module a reason to change? |
| Open/closed | Can a likely variant be added without rewriting stable policy? |
| Liskov substitution | Does every subtype preserve the promised preconditions, postconditions, and invariants? |
| Interface segregation | Is each client forced to depend on operations it does not use? |
| Dependency inversion | Does stable policy depend on volatile mechanism, or the reverse? |

Applying every rule mechanically produces interface inflation, speculative extension points, and behavior scattered across files. A two-case conditional may be clearer than a plugin architecture. “Single responsibility” is not “one method”; a cohesive module can coordinate several steps of one policy.

Use SOLID after identifying actual change pressure and pain. Name the violated contract, show the coupled change, and propose the smallest boundary that localizes it. Then include runtime and data architecture: object-level elegance does not compensate for a shared database or synchronous dependency chain.

<!-- FILE: book/chapters/part-08/chapter-06-state-mutation-and-error-handling.md -->
## 8.6 - State, Mutation, and Error Handling {#chapter-08-06}

Mutable state is where time enters a program. If many components can change the same data, reasoning requires knowing every possible order. Reduce the mutation surface, make transitions explicit, and keep one owner for each invariant.

Immutability simplifies sharing and rollback but can increase allocation or copying. Persistent data structures and copy-on-write trade memory for safer versions. Local mutation inside an encapsulated operation is often clearer than a globally immutable design with accidental complexity.

Errors need a taxonomy. Domain rejections, invalid input, transient dependency failures, resource exhaustion, bugs, and cancellation demand different handling. Preserve the causal chain while translating infrastructure errors into stable boundary semantics. Never retry an unknown failure without an idempotency and budget analysis.

Exceptions work for nonlocal propagation; result types make expected alternatives visible. Either can be abused. Do not catch an error merely to log and rethrow at every layer, and do not turn programmer defects into ordinary business results.

Resource ownership must survive failure: use structured cleanup, bounded concurrency, cancellation propagation, and transactions/compensation where state spans boundaries.

<!-- FILE: book/chapters/part-08/chapter-07-maintainable-change.md -->
## 8.7 - Maintainable Change {#chapter-08-07}

Maintainability is the ability to change behavior safely at an acceptable cost. It emerges from clear contracts, localized decisions, fast feedback, observable production behavior, and a codebase whose structure matches ownership.

Before changing code, identify the invariant and all readers/writers of the affected state. Make the change in a compatibility sequence when deployments are independent. Tests should pin behavior, not implementation trivia. Logs, metrics, and traces should reveal rollout impact.

Technical debt is a future change tax, not “code I dislike.” Record the constrained change, recurring cost, risk, and a trigger for repayment. Some duplication is cheaper than premature unification; merge it when the duplicated concepts change for the same reason.

A staff engineer improves the change system: simpler paved roads, dependency rules, automated migrations, safe defaults, ownership maps, and removal of obsolete paths. The goal is not architectural purity but sustained delivery without accumulating hidden operational risk.

::: {.interview-tip}
**Interview Tip**

Describe how the design behaves under the next likely change, partial rollout, failure, and rollback. That is more revealing than naming patterns.
:::

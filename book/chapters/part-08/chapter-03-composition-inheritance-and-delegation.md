## 8.3 - Composition, Inheritance, and Delegation {#chapter-08-03}

Composition builds behavior from owned collaborators. Delegation forwards responsibility to a collaborator. Inheritance binds a subtype to a parent contract and often to protected implementation details.

Prefer composition when capabilities vary independently, must be replaced in tests, or have distinct lifecycles. Prefer inheritance when the subtype genuinely preserves the parent’s semantics and the hierarchy is stable. Framework-required inheritance may be pragmatic; isolate it at the boundary.

Deep hierarchies create the fragile-base-class problem: a parent change affects descendants in nonlocal ways. Composition can create its own maze of tiny interfaces and forwarding layers. The criterion is not ideology but whether the design makes state, ownership, and control flow easy to trace.

Delegation is particularly useful for policy: a retrying client delegates transport, a service delegates authorization, and a repository delegates persistence. Decorators can layer cross-cutting behavior, but ordering becomes part of the contract—retry outside a transaction differs from retry inside it.

::: {.gotcha}
**Gotcha**

“Favor composition” does not mean wrap every class. Each collaborator should own a coherent decision or boundary.
:::

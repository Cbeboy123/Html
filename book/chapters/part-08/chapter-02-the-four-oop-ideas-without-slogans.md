## 8.2 - The Four OOP Ideas Without Slogans {#chapter-08-02}

**Encapsulation** protects an invariant by controlling state transitions; private fields alone do not achieve it if mutable internals escape. **Abstraction** presents the essential contract. **Polymorphism** lets different implementations satisfy that contract. **Inheritance** reuses or specializes behavior through an “is-a” relationship, but also couples child behavior to parent assumptions.

Consider a rate limiter. Encapsulation keeps token counts and time updates valid. Its interface abstracts `allow(request)`. Polymorphism permits local and distributed implementations. Inheritance is optional; both implementations can compose clocks and stores instead.

Dynamic dispatch moves selection from explicit conditionals to implementations. That is valuable when variants evolve independently, but harmful when it obscures a closed, simple decision. Algebraic data types, pattern matching, modules, traits, protocols, and functions can express the same design forces in non-class-centric languages.

The goal is replaceable behavior with preserved semantics. A subtype that throws for a base operation, strengthens preconditions, or weakens postconditions is not safely substitutable even if the compiler accepts it.

::: {.interview-tip}
**Interview Tip**

Define each idea by the change or invariant it manages. Avoid explaining all four with “reuse.”
:::

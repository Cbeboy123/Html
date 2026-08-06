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

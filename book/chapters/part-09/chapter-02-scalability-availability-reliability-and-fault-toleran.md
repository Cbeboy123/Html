## 9.2 - Scalability, Availability, Reliability, and Fault Tolerance {#chapter-09-02}

These properties are related but distinct. **Scalability** is the ability to handle growth by adding or changing resources without unacceptable degradation. **Availability** is the proportion or probability of successful service at defined boundaries. **Reliability** is continued correct behavior over time. **Fault tolerance** is preserving a specified service despite specified faults.

Define the service first. A read-only status page may be available while checkout is unavailable. A response can be fast and wrong. “Five nines” is meaningless without population, window, exclusions, and success criteria.

Vertical scaling increases one node’s capacity; horizontal scaling distributes work. Stateless request handling eases horizontal scaling, but state still exists in databases, caches, sessions, queues, and rate limits. Amdahl’s law reminds us that an unscaled serial fraction bounds total speedup.

Redundancy improves fault tolerance only when replicas do not share the failing dependency. It also adds modes: stale data, split brain, failover, and repair. Use error budgets to balance reliability work with change, and test fault assumptions through controlled exercises.

::: {.interview-tip}
**Interview Tip**

Give a metric and failure scope for each “-ility.” Do not use availability and reliability as synonyms.
:::

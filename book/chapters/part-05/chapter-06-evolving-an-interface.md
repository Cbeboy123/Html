## 5.6 - Evolving an Interface {#chapter-05-06}

Distributed rollout creates a compatibility window: old and new producers and
consumers coexist. Safe change plans for that window rather than assuming an
atomic deployment.

An expand-and-contract sequence is durable:

1. Add a representation the old system can ignore or coexist with.
2. Deploy readers that understand both old and new forms.
3. Migrate producers and stored data while measuring usage.
4. Stop producing the old form.
5. Remove old reading only after evidence shows it is unused.

Breaking changes include renamed meaning, narrowed ranges, new required fields,
changed authorization, reordered events, and altered error behavior—even when
the wire schema validates.

Deprecation needs ownership, discovery of consumers, a deadline, migration
guidance, and observability. A header or version number without a retirement
process creates permanent parallel APIs.

For events, immutable historical data may outlive the code that wrote it.
Consumers replaying old data need schemas and semantics for the retained
history. Upcasting at read time can help, but must be deterministic and tested.

Contract tests verify a provider and known consumers against shared
expectations. They complement, rather than replace, end-to-end and failure
testing.

::: {.interview-tip}
**Interview Tip**

Describe coexistence and rollback. “Deploy both sides together” is not a safe
interface-evolution strategy across independent services.
:::

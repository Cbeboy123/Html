## 13.8 - The Production Readiness Review {#chapter-13-08}

A production readiness review is not a document ceremony. It is a structured attempt to find missing ownership, unsafe defaults, and untested recovery before customers find them.

### 1. State the service contract

Write the service in one paragraph:

- users and critical operations;
- authoritative data and derived data;
- latency, availability, freshness, and correctness expectations;
- traffic shape and data size;
- dependencies and regions;
- privacy and security classification;
- explicit non-goals.

If the service contract is unclear, capacity and reliability choices cannot be judged.

### 2. Define a small number of SLIs and SLOs

An **SLI** is a measured service indicator. An **SLO** is its target. An **SLA** is a commitment with consequences. Measure at the user-relevant boundary where possible.

For a request API, useful indicators often include valid-request success rate, latency distribution, and correctness. A pipeline may care more about completion freshness and backlog age. A storage service also needs durability.

99.9% monthly availability allows about 43 minutes and 50 seconds of unsuccessful time in a 30.44-day average month if measured purely by time. Request-based availability may be a better model for a global service. Always define the numerator, denominator, window, and exclusions.

::: {.fact}
**Surprising Fact - Reliability far above the stated SLO can be risky**

Users build dependencies on observed behavior, not only written promises. Google SRE describes deliberately testing unusually reliable dependencies so hidden assumptions fail in a controlled setting instead of during a rare outage.
:::

### 3. Capacity and overload

Record tested sustainable throughput, bottleneck, safe operating headroom, and behavior during a burst. Every pool and queue needs an owner, limit, and rejection path. Test cache loss, slow database, retry storms, hot tenants, and recovery while backlog exists.

Autoscaling needs a signal, startup time, quota, and downstream capacity. It is a slower control loop than admission control.

### 4. Security and privacy

Draw trust boundaries and data flows. For each entry point, define authentication, object-level authorization, input limits, rate policy, and audit events. Use short-lived workload identity and managed secrets. Protect the CI/CD system because it can change all shipped code.

Current NIST SP 800-63-4 guidance treats authentication assurance and authenticator lifecycle as explicit design concerns. Phishing-resistant authenticators improve resistance to credential theft, but account recovery, session management, authorization, and monitoring still matter.

Do not collect data “in case it is useful.” State purpose, retention, access, deletion, backup, and incident handling. Telemetry can contain personal or secret data and needs the same care as application data.

### 5. Observability as questions

OpenTelemetry groups telemetry into traces, metrics, logs, baggage, and evolving signals such as profiles. The tool names matter less than the questions:

- Can we find one failed request across services?
- Can we separate queue time from service time?
- Can we locate the first failed boundary?
- Can we see saturation before user impact?
- Can we verify a rollout by version and cohort?
- Can we detect dropped telemetry and cardinality growth?

High-cardinality values such as user IDs and request IDs usually belong in traces or structured logs, not unrestricted metric labels.

### 6. Deployment and data change

Produce one immutable artifact and promote it. Separate deployment from feature release. Use progressive exposure with success and rollback criteria. Database and message changes must support mixed versions.

Rollback is valid only if new code has not written data that old code cannot understand. Otherwise plan a roll-forward, compatibility adapter, or repair migration.

### 7. Recovery and incidents

Define RPO and RTO from business impact. Test restore, failover, credential loss, dependency loss, and regional capacity. Replication is not backup; it can copy deletion and corruption.

An incident needs a commander, technical work leads, communications owner, and shared timeline. Restore service with reversible actions first. Preserve evidence. Investigate cause after the system is stable.

### 8. Ownership and staff judgment

Every critical alert, dashboard, runbook, dependency, dataset, and migration needs an owner. A staff engineer makes the decision system better, not themselves the permanent decision bottleneck.

Use a short decision record:

~~~text
Context: What changed and why now?
Decision: What will we do?
Invariants: What must remain true?
Alternatives: What credible options were rejected, and why?
Failure model: Which faults are covered or not covered?
Migration: How do old and new states coexist?
Evidence: What test or metric will tell us the decision works?
Reversal: How can we stop, roll back, or repair?
Owner and review date: Who checks the result, and when?
~~~

### Final launch questions

- What happens when every dependency is slow rather than fully down?
- What happens after a timeout when the write may have committed?
- Which queue grows first and how is it bounded?
- Can one tenant or key consume shared capacity?
- Can the previous version read data written by the new version?
- How do we revoke a leaked credential immediately?
- What customer-visible signal triggers rollback?
- When was the last successful restore or failover test?
- Who has authority during an incident?
- What manual repair path exists when automation cannot decide?

::: {.interview-tip}
**Staff-Level Answer**

Connect architecture to a measurable user outcome, migration sequence, failure model, and ownership. Staff engineering is the ability to make a system and an organization safer to change.
:::


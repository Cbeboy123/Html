## 9.11 - High Availability and Safe Lifecycle {#chapter-09-11}

High availability is an end-to-end property. Redundant instances behind one database, DNS zone, credential issuer, or deployment controller still share that dependency. Map failure domains and the control plane needed to recover them.

Safe startup requires dependency discovery, migrations compatible with mixed versions, and readiness only after the instance can serve correctly. Safe shutdown stops admission, marks unready, drains bounded work, transfers leases/partitions, flushes required state, and exits before forced termination.

Rolling deployments need backward- and forward-compatible protocols. Database changes follow expand/migrate/contract. Feature flags decouple exposure from deployment but require ownership, observability, expiry, and safe default behavior.

Failover is not complete at leader election: clients must discover the new endpoint, stale connections must fail, caches converge, capacity absorb traffic, and old leaders be fenced. Test RTO and RPO through restore and regional exercises, including control-plane impairment.

::: {.scenario}
**Real-World Scenario**

A regional failover succeeds technically, but the secondary region has cold caches and half the database connection limit. Retry traffic overwhelms it. Availability planning must include recovery load, not just idle replica count.
:::

## 12.5 - Senior and Staff Interview Drills {#chapter-12-05}

Practice these aloud with a five-minute mechanism answer, then a fifteen-minute failure deep dive:

1. A service slows only at p99. Separate queueing, CPU, GC, database, and downstream hypotheses.
2. A payment request times out. Explain ambiguous outcome, retry safety, status lookup, and reconciliation.
3. Kafka lag grows after a deployment. Trace partition assignment, processing latency, commits, poison records, and rebalances.
4. Two leaders write after a network partition. Explain quorum, leases, and fencing.
5. A database read is stale after failover. Name replication, consistency, routing, and session guarantees.
6. A cache outage takes down the database. Design admission, single-flight, fallback limits, and recovery.
7. Add a required API field with zero downtime. Give the expand-and-contract sequence and observability.
8. Rotate a signing key. Explain overlapping keys, issuer/audience verification, cache refresh, and rollback.
9. Design a safe regional failover. Include capacity, DNS/connections, data loss, fencing, and drills.
10. Lead a cross-team reliability program. Define outcome, influence, migration, ownership, and measures.

Score each answer from 0–2 on framing, mechanism, failure, tradeoff, evidence, and decision. Redo weak dimensions rather than memorizing a longer script.

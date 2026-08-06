## 12.3 - End-to-End Failure Tracing {#chapter-12-03}

Trace failures as a ledger of boundaries:

| Boundary | Question | Evidence |
|---|---|---|
| Caller | What outcome and deadline did the user observe? | Client event, request ID, user-facing SLI |
| Edge/network | Did name resolution, connect, TLS, and routing succeed? | DNS response, connection timing, edge logs |
| Admission | Was work accepted, queued, throttled, or rejected? | Queue depth, limiter decision, saturation |
| Service | Which version/path handled it and for how long? | Trace span, structured error, profile |
| Dependency | Was time spent waiting, executing, retrying, or transferring? | Child spans and server-side metrics |
| Durable state | What committed, replicated, or remained ambiguous? | Transaction/event IDs, WAL/broker evidence |
| Async effect | Was it published, consumed, applied, and acknowledged? | Offsets, dedup key, outbox/inbox state |
| Recovery | Did repair converge and backlogs drain? | Reconciliation counts, lag, invariant checks |

Move outside-in until evidence crosses the failing boundary. Separate service time from queueing and original work from retry attempts. Align events through trace causality when host clocks differ.

The final causal statement should explain impact, mechanism, trigger, contributing conditions, and failed defense. “Database was slow” is a symptom; “an estimate error chose a spilling join, exhausted the pool, and retries saturated admission” is a testable chain.

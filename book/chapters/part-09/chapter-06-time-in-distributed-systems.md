## 9.6 - Time in Distributed Systems {#chapter-09-06}

Wall clocks approximate civil time and can jump due to synchronization or administrative change. Monotonic clocks measure elapsed duration on one machine and should not move backward, but their readings are not comparable across hosts. Use wall time for human timestamps, monotonic time for local deadlines, and explicit logical order for causality.

NTP-style synchronization reduces error; it does not create perfect global time. Clock skew and uncertainty make “latest timestamp wins” a conflict policy that can discard a valid later action from a slow clock.

Lamport clocks assign counters so causal order implies increasing values, but equal ordering does not reveal concurrency fully. Vector clocks/version vectors track causality across participants at greater metadata cost. Hybrid logical clocks combine physical proximity with logical monotonicity under stated assumptions.

Deadlines should carry a remaining budget, not a wall-clock expiry blindly compared on another host. Expiration, leases, token validity, audit time, and event time each need their own semantics. Event-time streaming also distinguishes when an event occurred from when it arrived and uses watermarks to bound waiting for late data.

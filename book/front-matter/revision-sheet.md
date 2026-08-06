# Night-Before Revision Sheets {.unnumbered}

## I - Computation, Data, and Runtimes {.unnumbered}

- Locate CPU, memory, I/O, network, and queueing cost; latency is not throughput.
- Bytes need width, signedness, order, schema, and text encoding.
- Unicode code points, UTF-8 bytes, and grapheme clusters are distinct.
- Floating point is finite representation; exactness is a domain decision.
- Big-O describes growth, not latency; locality and boundary crossings matter.

## II - OS, Memory, and Concurrency {.unnumbered}

- Processes own protected resources; threads share process state and have stacks.
- Virtual address space, resident memory, and durable backing are different.
- Coherence does not make races safe; draw the happens-before edge.
- Protect an invariant and progress; distinguish deadlock, livelock, and starvation.
- Visibility of bytes is not crash durability.

## III - Networks and the Web {.unnumbered}

- Frame on a link, IP packet across routes, transport stream/datagram, HTTP message.
- Route first, then resolve the next hop; DNS is cached delegated authority.
- TCP supplies an ordered byte stream, not message boundaries or business commit.
- TLS authenticates endpoints and protects records between termination points.
- Every proxy changes routing, timeout, observation, and often trust boundaries.

## IV - The URL Journey {.unnumbered}

- Begin with URL parsing, local policy, cache, service worker, and connection reuse.
- Then DNS, route, transport, TLS/QUIC, edge, application, data, response, render.
- Separate backend first byte from user-ready rendering.
- Build a latency ledger; include queues and retries at every hop.
- Follow evidence outside-in until it crosses the failing boundary.

## V - APIs, Serialization, and Messaging {.unnumbered}

- A contract includes meaning, units, errors, limits, compatibility, and security.
- Remote calls have partial failure and ambiguous outcomes; carry deadlines.
- Messaging moves the receive/effect/ack crash window to the consumer.
- Ordering has a scope; “JSON parses” does not mean semantic compatibility.
- Evolve interfaces through expand, coexist, migrate, observe, and contract.

## VI - Databases and Data Models {.unnumbered}

- WAL becomes durable before dirty pages; recovery replays the ordered protocol.
- Constraints arbitrate concurrent invariants better than prior application reads.
- ACID consistency differs from replica consistency; snapshot differs from serializable.
- Indexes trade write/storage cost for selected access; inspect estimates and rows.
- Replication, partitioning, sharding, and backup solve different problems.

## VII - Kafka and Distributed Logs {.unnumbered}

- Ordering and offsets are per partition; consumers own progress.
- Trace serialize, partition, batch, leader ack, replication, fetch, effect, commit.
- Effect before offset commit gives duplicates; commit before effect risks loss.
- Rebalance is ownership transfer; retention is not acknowledgment.
- Exactly-once guarantees end at the participating transaction boundary.

## VIII - Abstraction and Maintainable Design {.unnumbered}

- An abstraction hides choices, not costs and failures callers must handle.
- Encapsulation protects invariants; polymorphism preserves a semantic contract.
- Choose the simplest composition or hierarchy localizing a real change.
- Coupling includes data, time, deployment, and operational fate—not only imports.
- Staff leverage improves the system of change, ownership, and safe defaults.

## IX - Distributed Systems {.unnumbered}

- Partial failure makes timeout outcomes ambiguous.
- Quorums require versions, election, placement, and repair to be useful.
- Consensus orders decisions; fencing stops stale leaders at the protected resource.
- State consistency per operation and observer; CAP is about partition behavior.
- Bound retries, propagate deadlines, shed load, and design reconciliation.

## X - Security {.unnumbered}

- Begin with assets, actors, abuse cases, data flows, and trust boundaries.
- Hash, MAC, signature, and authenticated encryption give different properties.
- Authentication establishes identity; authorization permits one resource action.
- OAuth delegates access; OIDC adds identity; JWT is only a token format.
- Secure delivery, secrets, detection, response, and isolated backups form one system.

## XI - Delivery and Operations {.unnumbered}

- Tests buy evidence against named risk; CI promotes one immutable artifact.
- Separate deployment from release; plan mixed versions and data rollback.
- Logs, metrics, and traces answer different questions; control cost/cardinality.
- Define user-facing SLIs/SLOs and alert on meaningful error-budget burn.
- Incidents prioritize restoration, evidence, clear roles, and verified learning.

## XII - Staff-Level Synthesis {.unnumbered}

- Frame, define, trace mechanism, fail it, state tradeoff, demand evidence, decide.
- For each guarantee: property, scope, failures, observer, time, mechanism, repair.
- Distinguish service time from queueing and original work from retry attempts.
- When stuck, ask what crossed the boundary, what committed, who acknowledged, and
  what evidence remains.

## 9.4 - Failure Detection, Election, and Consensus {#chapter-09-04}

Failure detectors infer from missing evidence. A timeout too short causes false suspicion; too long delays recovery. Networks can partition so both sides remain alive. Election must therefore establish exclusive authority, not merely choose the fastest volunteer.

**Consensus** lets nodes agree on a sequence/value despite failures within a model. Leader-based protocols such as Raft replicate a log: a majority elects a leader; entries become committed under protocol rules; followers apply the committed order. Paxos and Raft differ in exposition and mechanics, but neither makes an unavailable majority writable.

~~~mermaid
sequenceDiagram
    participant L as Leader, term 8
    participant F1 as Follower 1
    participant F2 as Follower 2
    L->>F1: Append entry at index 42
    L->>F2: Append entry at index 42
    F1-->>L: Persisted
    F2-->>L: Persisted
    L->>L: Majority reached; commit
~~~

*Diagram key: solid arrows = replication; dashed arrows = acknowledgments; self-step = commit decision under the protocol.*

Use **fencing tokens**—monotonically increasing authority numbers—when an old leader might resume. The protected resource rejects stale tokens, turning uncertain liveness into enforceable safety.

::: {.gotcha}
**Gotcha**

A distributed lock lease without fencing can expire while the old holder is paused; both old and new holders may then act.
:::

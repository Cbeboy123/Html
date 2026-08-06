## 7.8 - Retention, Deletion, and Log Compaction {#chapter-07-08}

Time/size retention deletes old log segments regardless of whether every consumer processed them. Retention is therefore a storage policy, not an acknowledgment protocol. A consumer whose outage exceeds retention must recover from another source or accept a gap.

**Log compaction** retains the latest record for each key eventually, while preserving ordering of retained records and allowing old values to remain until compaction runs. A tombstone marks deletion; tombstones themselves need a retention window so replicas and offline consumers can observe the delete.

Compaction enables changelog and state-rebuild patterns, not a point-in-time database snapshot. Keys are part of the data model: changing serialization or key meaning can strand historical state. Null keys, large keys, skew, and high update churn also affect storage behavior.

Choose policy from recovery needs:

| Need | Suitable basis |
|---|---|
| Replay every recent event | Time/size retention |
| Rebuild latest keyed state | Compaction |
| Both recent history and long-lived latest state | Combined policy, tested carefully |

Capacity planning includes retained bytes, replication factor, segment overhead, temporary compaction space, and replica movement headroom.

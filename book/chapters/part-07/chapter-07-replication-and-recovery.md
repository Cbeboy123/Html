## 7.7 - Replication and Recovery {#chapter-07-07}

Followers fetch the leader’s log and persist replicas. A partition’s in-sync replica set tracks followers eligible under configured freshness rules. When a leader fails, the controller elects a replacement from eligible replicas and clients refresh metadata.

~~~mermaid
flowchart TB
    leader[(Broker A: leader log)] ==> f1[(Broker B: follower)]
    leader ==> f2[(Broker C: follower)]
    controller[Metadata controller] -->|leader fails| election{Eligible replica?}
    election -->|B elected| f1
    election --x|none| unavailable{Partition unavailable}
~~~

*Diagram key: cylinders = replica logs; rectangle = controller; diamond = election condition; thick arrows = replication; cross-ended arrow = unavailable outcome.*

Replication provides a choice among latency, availability, and acknowledged-data risk. If the ISR falls below the configured minimum, strict production may reject writes rather than acknowledge under-replicated data. Allowing an out-of-sync replica to lead can restore availability by discarding a divergent tail; that is a conscious data-loss policy.

Recovery time depends on detection, election, metadata propagation, client retry, replica catch-up, and storage condition. A three-replica topic is not resilient if all replicas share one failure domain. Placement must cross the zones, racks, power, and operational boundaries the availability target assumes.

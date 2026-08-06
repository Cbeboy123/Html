## 9.3 - Replication and Quorums {#chapter-09-03}

Replication keeps copies for availability, locality, read scale, or durability. Synchronous replication waits for defined replicas before acknowledgment; asynchronous replication reduces foreground latency but permits lag and possible acknowledged-data loss after failover.

A quorum chooses intersecting read and write sets. In a simplified system with `N` replicas, write quorum `W`, and read quorum `R`, `W + R > N` creates overlap. That arithmetic alone does not guarantee linearizability: versions, leader rules, conflict resolution, failure detection, and sloppy placement still matter.

~~~mermaid
flowchart TB
    client([Client]) --> coordinator[Coordinator]
    coordinator ==> a[(Replica A)]
    coordinator ==> b[(Replica B)]
    coordinator ==> c[(Replica C)]
    a --> q{Enough valid acknowledgments?}
    b --> q
    c --> q
    q -->|yes| ok([Complete])
    q --x|no before deadline| fail{Unavailable or ambiguous}
~~~

*Diagram key: rounded boxes = external outcomes; rectangle = coordinator; cylinders = replicas; thick arrows = replication; diamond = quorum condition; cross-ended arrow = failed completion.*

Repair is part of replication: followers catch up, divergent versions reconcile, and checksums or anti-entropy find missed data. A replica count without placement and repair objectives is not an availability design.

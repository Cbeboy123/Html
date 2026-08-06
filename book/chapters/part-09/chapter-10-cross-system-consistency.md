## 9.10 - Cross-System Consistency {#chapter-09-10}

A local transaction cannot atomically update an independent database and broker by ordinary writes. Two-phase commit can coordinate prepared participants but has availability, blocking, and operational costs; many external systems do not support it.

The **transactional outbox** writes domain state and an outbox row in one database transaction. A relay publishes rows and marks progress; publication may repeat, so consumers remain idempotent. Change data capture can serve as the relay, but schema, ordering, replay, and connector operations become part of the contract.

~~~mermaid
flowchart LR
    api[Business transaction] --> db[(Domain rows + outbox)]
    db ==> relay[Outbox relay or CDC]
    relay -.-> log{{Event log}}
    log -.-> consumer[Idempotent consumer]
    consumer --> view[(Derived state)]
~~~

*Diagram key: cylinder = durable state; hexagon = async log; rectangles = active processes; thick arrow = sustained capture; dashed arrows = asynchronous delivery.*

A **saga** coordinates several local transactions through commands/events and compensating actions. Compensation is a new business action, not time travel: a refund may fail and cannot erase that an email was seen. Persist saga state, make steps idempotent, define deadlines, and provide reconciliation/manual repair.

The staff-level guarantee is often convergence with detection and repair, not impossible global atomicity.

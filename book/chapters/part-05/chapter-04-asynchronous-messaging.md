## 5.4 - Asynchronous Messaging {#chapter-05-04}

Messaging lets a producer hand off work without requiring the consumer to be
available at that instant. The broker creates temporal decoupling, not automatic
correctness.

~~~mermaid
flowchart LR
    producer[Producer] -.-> channel{{Queue, topic, or log}}
    channel -.-> c1[Consumer A]
    channel -.-> c2[Consumer B]
    c1 --> effect[(Business state)]
    c1 --x|processing fails| retry{{Retry or dead-letter path}}
~~~

*Diagram key: rectangles actively process; hexagons are asynchronous channels;
cylinder is persisted business state; dashed arrows are message delivery;
cross-ended arrow is a failed processing path.*

A queue commonly assigns each item to one competing consumer. Publish/subscribe
delivers an event to multiple subscriptions. A retained log lets consumers track
positions and replay within retention. Products combine these abstractions in
different ways.

Acknowledgment defines when the broker may treat delivery as handled. Ack before
the business effect risks loss; effect before ack risks duplicate processing.
Idempotent effects or transactional coordination handle that gap.

Ordering is scoped. A broker may order within a partition, session, or queue
while concurrent consumers complete out of order. Define the entity whose order
matters and route/serialize accordingly.

A **poison message** repeatedly fails deterministic processing. Blind retry
blocks progress or burns capacity. Quarantine with diagnostic context, alert,
and a replay policy that avoids silent loss.

::: {.interview-tip}
**Interview Tip**

Trace “receive, effect, acknowledge, crash” at every boundary. That reveals
delivery semantics more reliably than naming a broker mode.
:::

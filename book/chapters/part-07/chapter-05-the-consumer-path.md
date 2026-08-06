## 7.5 - The Consumer Path {#chapter-07-05}

Consumers pull batches from partition leaders. Pulling lets a consumer pace delivery and exploit batching, but the application must keep polling, process records, and manage progress correctly.

~~~mermaid
flowchart LR
    leader[(Partition leader)] ==> fetch[Fetch batches]
    fetch --> process[Process records]
    process --> effect[(Business effect)]
    process --> commit[Commit next offset]
    commit -.-> offsets[(Group offset store)]
~~~

*Diagram key: cylinders = retained state; rectangles = consumer stages; thick arrow = batched stream; dashed arrow = progress update.*

A committed offset normally represents the next record to read. Commit before the business effect risks loss; effect before commit risks repetition after a crash. The usual design accepts at-least-once delivery and makes the effect idempotent, or atomically coordinates effect and progress where the platform permits.

Automatic offset commit can be correct only when its timing matches processing. Long processing also interacts with group liveness. A robust consumer separates bounded fetching, processing, retry/quarantine, and commit policy while preserving order where required.

Lag is the distance between available and consumed positions. It is not itself elapsed time, and a stable offset lag can represent very different delay at different traffic rates. Monitor record lag, time lag where meaningful, processing latency, errors, and consumer saturation together.

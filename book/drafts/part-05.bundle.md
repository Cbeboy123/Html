<!-- FILE: book/chapters/part-05/chapter-01-contracts-across-process-boundaries.md -->
## 5.1 - Contracts Across Process Boundaries {#chapter-05-01}

Inside one process, a refactor can update caller and callee together. Across a
process boundary, deployments, failures, and clocks are independent.

A **contract** defines valid messages and their meaning: field syntax, units,
invariants, error semantics, ordering, compatibility, authentication, and
operational limits. A schema describes shape; it does not fully describe
behavior.

Contracts should distinguish required from optional information and unknown from
invalid values. Defaults are part of semantics: introducing a default can change
old consumers even when parsing succeeds.

Compatibility has direction:

- A new reader consuming old data needs backward-reading compatibility.
- An old reader consuming new data needs forward-reading compatibility.
- Independently deployed peers often need both during rollout.

A “tolerant reader” may ignore unknown fields, but excessive tolerance can hide
misspellings and broken producers. Validate what affects correctness and preserve
unknown data only when the format and use case require it.

Network calls have ambiguous outcomes. A timeout says the caller did not observe
completion; it does not prove the callee did nothing. Contracts for state change
need idempotency, status lookup, or reconciliation.

::: {.interview-tip}
**Interview Tip**

Discuss semantic compatibility, not only whether JSON still parses. Units,
defaults, invariants, and error meaning are contract surface.
:::

<!-- FILE: book/chapters/part-05/chapter-02-resource-oriented-http-apis.md -->
## 5.2 - Resource-Oriented HTTP APIs {#chapter-05-02}

REST is an architectural style with constraints including a uniform interface,
stateless requests, cacheability, and layered components. An endpoint returning
JSON over HTTP is not automatically RESTful.

HTTP method semantics matter. GET is safe and idempotent by intent. PUT requests
a selected resource state and is idempotent by intent. DELETE is idempotent in
requested effect even if later responses differ. POST has broad processing
semantics and can still be made retry-safe with an application idempotency key.

Resource identifiers should remain stable while representations evolve. Status
codes and structured error bodies serve different purposes: the code supports
generic HTTP handling; the body carries domain-specific details without leaking
sensitive internals.

Pagination must define ordering. Offset pagination is simple but can skip or
duplicate items when concurrent changes shift positions. Cursor pagination can
bind progress to a stable ordering key, but cursors need integrity and version
policy.

Conditional requests use validators such as ETags. A client can send a
precondition to prevent lost updates rather than performing an unsafe
read-modify-write sequence.

Version only when compatibility cannot be preserved. Whether the version lives
in a path, media type, or header is less important than coexistence,
observability, deprecation, and migration.

::: {.gotcha}
**Gotcha**

Returning HTTP 200 with an error field prevents intermediaries and generic
clients from applying ordinary HTTP failure semantics.
:::

<!-- FILE: book/chapters/part-05/chapter-03-rpc-and-grpc.md -->
## 5.3 - RPC and gRPC {#chapter-05-03}

**Remote procedure call** makes a network interaction resemble a function call.
The resemblance is convenient but incomplete: a remote call has latency,
partial failure, serialization, independent deployment, and ambiguous outcome.

gRPC commonly uses Protocol Buffers contracts and HTTP/2 transport. It supports
unary and streaming interaction patterns. Generated clients provide type-safe
stubs, but cannot make semantic changes compatible automatically.

Every call needs a deadline derived from the caller’s end-to-end budget.
Cancellation should propagate where safe, but the server may already have
committed work. Retries require idempotency and knowledge of whether a failure
occurred before or after application handling.

Streaming adds flow control and lifecycle concerns. A slow receiver must apply
backpressure; unbounded buffering merely moves the failure into memory.
Long-lived streams also interact with load balancing, deployment draining, and
connection failure.

RPC is a good fit for strongly contracted service-to-service operations.
Resource-oriented HTTP can be easier for public APIs, caching, and broad tooling.
Messaging fits decoupled or asynchronous work. These are tradeoffs, not a ladder
of modernity.

::: {.interview-tip}
**Interview Tip**

Say “location transparency is partial.” The interface may look local, but
failure and time semantics must remain visibly remote.
:::

<!-- FILE: book/chapters/part-05/chapter-04-asynchronous-messaging.md -->
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

<!-- FILE: book/chapters/part-05/chapter-05-serialization-formats.md -->
## 5.5 - Serialization Formats {#chapter-05-05}

Serialization converts structured values into bytes; deserialization reconstructs
values under a schema or interpretation. The format choice affects
interoperability, evolution, inspection, and performance.

| Format | Strength | Main caution |
|---|---|---|
| JSON | Human-readable, broad tooling | Numbers, binary data, and schema require policy |
| Protocol Buffers | Compact tagged fields and generated contracts | Field-number reuse and semantic changes break evolution |
| Avro | Schema-driven data with strong data-pipeline use | Reader/writer schema resolution must be operated correctly |

Size claims depend on data and encoding choices; benchmark representative
messages instead of repeating universal ratios. Compression can dominate format
size for large repetitive payloads.

Schema evolution works when identifiers remain stable and old/new interpretations
agree. Adding an optional field is often compatible, but changing units or
meaning is not. Removing a field from code does not make its identifier safe to
reuse.

Deserialization is a trust boundary. Bound message size, nesting, collection
counts, and resource use. Avoid formats that instantiate arbitrary application
types from untrusted input.

Text fields still need an encoding, timestamps need a timeline/offset policy,
and decimals need scale/rounding semantics. A binary schema does not remove
domain ambiguity.

<!-- FILE: book/chapters/part-05/chapter-06-evolving-an-interface.md -->
## 5.6 - Evolving an Interface {#chapter-05-06}

Distributed rollout creates a compatibility window: old and new producers and
consumers coexist. Safe change plans for that window rather than assuming an
atomic deployment.

An expand-and-contract sequence is durable:

1. Add a representation the old system can ignore or coexist with.
2. Deploy readers that understand both old and new forms.
3. Migrate producers and stored data while measuring usage.
4. Stop producing the old form.
5. Remove old reading only after evidence shows it is unused.

Breaking changes include renamed meaning, narrowed ranges, new required fields,
changed authorization, reordered events, and altered error behavior—even when
the wire schema validates.

Deprecation needs ownership, discovery of consumers, a deadline, migration
guidance, and observability. A header or version number without a retirement
process creates permanent parallel APIs.

For events, immutable historical data may outlive the code that wrote it.
Consumers replaying old data need schemas and semantics for the retained
history. Upcasting at read time can help, but must be deterministic and tested.

Contract tests verify a provider and known consumers against shared
expectations. They complement, rather than replace, end-to-end and failure
testing.

::: {.interview-tip}
**Interview Tip**

Describe coexistence and rollback. “Deploy both sides together” is not a safe
interface-evolution strategy across independent services.
:::

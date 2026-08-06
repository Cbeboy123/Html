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

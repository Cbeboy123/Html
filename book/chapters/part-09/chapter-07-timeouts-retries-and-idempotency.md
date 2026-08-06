## 9.7 - Timeouts, Retries, and Idempotency {#chapter-09-07}

A timeout bounds how long a caller waits; it does not cancel reality. Set it from an end-to-end deadline and observed latency distribution, leaving time for handling failure. Each downstream hop should receive a smaller remaining budget.

Retries improve success for transient, independent failures. They worsen overload and duplicate ambiguous mutations. Use a bounded attempt count, exponential backoff, jitter, retry classification, and a shared deadline. Limit retries with budgets so one failing dependency cannot multiply fleet traffic.

An idempotent operation has the same intended effect when repeated. HTTP method labels help but do not protect business effects. For creation or payment, accept a client-generated idempotency key, bind it to a request fingerprint and caller, store the durable outcome, and return that outcome on repetition. Define key lifetime and concurrent-request behavior.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant S as Service
    participant D as Deduplication store
    C->>S: Mutate, key K
    S->>D: Claim K + request hash
    D-->>S: New claim
    S->>D: Store committed outcome
    C->>S: Retry, same K
    S->>D: Read K
    D-->>S: Return prior outcome
~~~

*Diagram key: solid arrows = requests/state changes; dashed arrows = deduplication decisions.*

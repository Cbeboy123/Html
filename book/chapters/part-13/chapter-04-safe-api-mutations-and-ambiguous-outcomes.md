## 13.4 - Safe API Mutations and Ambiguous Outcomes {#chapter-13-04}

The hardest API failures happen after a caller sends a state-changing request but before it receives a final response. The server may have done nothing, may still be working, or may have committed. The caller cannot infer which outcome from a timeout alone.

### Make the business operation identifiable

Give each logical mutation a stable operation ID or **idempotency key**. The key identifies the caller's intent, not one network attempt. The server should bind it to:

- authenticated caller or tenant;
- operation type and target;
- a hash of the important request fields;
- status and durable result;
- creation and expiry policy.

A simplified table might contain:

~~~text
idempotency_key | caller | request_hash | status | result_reference
~~~

Two requests with the same key but different request hashes are an error. Two concurrent requests with the same key need one owner: a unique constraint or atomic claim prevents both from executing.

### Put deduplication and effect in one boundary

If the business effect is stored in the same database, claim the idempotency key and commit the effect in one transaction. A durable successful result can then be returned to later retries.

~~~mermaid
sequenceDiagram
    participant C as Client
    participant A as API
    participant D as Database
    C->>A: Create payment, key K
    A->>D: Begin; claim K
    D-->>A: New key or previous result
    A->>D: Write payment and result for K; commit
    A-->>C: Result
    Note over C,A: If the response is lost, retry with K
~~~

*Diagram key: solid arrows are commands; dashed arrows are returned decisions or results; the note marks the ambiguous-response window.*

If the effect belongs to an external provider, local deduplication cannot make that provider atomic. Pass a provider-supported idempotency key where available, persist attempt state, query status, and reconcile. Money movement needs a ledger and repair process, not only HTTP retries.

### HTTP semantics help, but scope matters

- A safe method is intended not to request a state change.
- An idempotent method is intended to have the same requested effect when repeated.
- Responses to repetitions can differ. Repeating DELETE may first return success and later “not found” while the requested final state is still the same.
- POST can be made retry-safe with a well-designed idempotency key.

These are semantic contracts. A buggy handler can violate them.

::: {.fact}
**Worth Knowing - A timeout is an observation, not a rollback**

Stopping the client's wait does not reverse bytes already sent, code already running, or a transaction already committed. Cancellation is a separate best-effort protocol unless the system defines something stronger.
:::

### Prevent lost updates

A read-modify-write API can overwrite another caller's change:

1. Client A reads version 7.
2. Client B reads version 7.
3. A writes its change, producing version 8.
4. B writes based on version 7 and erases A's change.

Use optimistic concurrency with an expected version. In HTTP, an ETag plus `If-Match` can express the precondition. The authority updates only when the stored version still matches. A conflict response tells the client to reload or merge.

For invariants such as “only one active subscription,” use a database constraint or transaction. An application check followed by an insert races with another writer.

### Design errors as part of the contract

Separate:

- invalid input the caller can correct;
- authentication or authorization failure;
- business rejection such as insufficient balance;
- concurrency conflict;
- rate limit or overload;
- transient dependency failure;
- internal defect.

Do not leak stack traces, SQL, secrets, or internal topology. Return a stable machine-readable code, safe human message, correlation ID, and retry guidance only when retry is valid.

### Evolve without a synchronized deployment

Use expand-and-contract:

1. Add the new field or representation as optional/coexisting.
2. Deploy readers that understand old and new forms.
3. Change writers and migrate stored data.
4. Measure remaining old use.
5. Remove the old form only after the compatibility window closes.

Renaming a field's meaning, units, authorization, or default can break consumers even when JSON still parses.

### Mutation review checklist

1. What is the business operation ID?
2. Where is the serialization point?
3. What commits atomically?
4. What can repeat after every crash window?
5. How does the caller learn the final state after ambiguity?
6. Which constraint prevents concurrent invariant violation?
7. How are old and new clients supported during rollout?
8. Which metrics reveal duplicates, conflicts, and reconciliation debt?

::: {.interview-tip}
**Staff-Level Answer**

Trace send, receive, effect, commit, response, timeout, and retry. State which of those steps share one transaction. That exposes the real guarantee faster than saying “exactly once.”
:::


## 6.1 - From Durable Bytes to a Database {#chapter-06-01}

A database acknowledges a transaction, then the machine loses power. Recovery
must distinguish committed work from incomplete page updates.

Storage engines organize data into pages and keep frequently used pages in a
**buffer pool**. Modifying a cached page does not necessarily write that page
immediately. A **write-ahead log** (WAL) records recovery information before the
corresponding data-page changes are allowed to reach durable storage under the
engine’s protocol.

~~~mermaid
flowchart LR
    tx[Transaction changes] --> log[Append WAL records]
    log ==> durable[(Durable WAL)]
    tx --> dirty[Dirty buffer-pool pages]
    dirty -.->|later flush| pages[(Data files)]
    checkpoint[Checkpoint metadata] --> durable
    crash{Crash} --> recovery[Recovery scans log]
    durable --> recovery
    pages --> recovery
    recovery --> consistent[(Consistent database state)]
~~~

*Diagram key: rectangles are active engine stages; cylinders are persistent
state; dashed arrow is deferred page flush; thick arrow is required WAL
durability; diamond is a crash event.*

A **checkpoint** records a recovery boundary and coordinates background work so
recovery need not begin at the start of history. It does not necessarily mean
every cached page is written at one instant. Exact checkpoint algorithms vary.

Recovery commonly re-establishes effects that should be present and removes or
ignores effects of incomplete transactions. The precise redo/undo protocol is
engine-specific. The durable principle is ordered logging plus an idempotent
recovery procedure.

Torn writes, corrupted storage, lost acknowledgments, and misconfigured
durability expose assumptions beneath the engine. Replication is not a backup:
it can faithfully copy deletion or corruption.

::: {.interview-tip}
**Interview Tip**

Explain why WAL permits random page updates to be flushed later while preserving
recovery. Do not say “commit writes every changed table page to disk.”
:::

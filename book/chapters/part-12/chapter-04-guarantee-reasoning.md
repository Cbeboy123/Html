## 12.4 - Guarantee Reasoning {#chapter-12-04}

Use a guarantee ledger before accepting words such as “durable,” “ordered,” or “exactly once.”

| Question | Example |
|---|---|
| What property? | No two successful reservations consume the same unit |
| At which boundary? | Inventory authority, not search cache |
| For which operations/data? | Commit of one SKU in one region |
| Under which failures? | One process crash and retry; not total regional loss |
| Who observes it? | Successful API callers and reconciliation job |
| When does it hold? | At commit response, or eventually within five minutes |
| Which mechanism enforces it? | Unique constraint plus idempotency record |
| How is violation detected/repaired? | Invariant query, alert, compensating release |

Then walk the failure windows. Crash before effect, after effect before acknowledgment, during retry, during leadership change, and after partial rollout. For concurrency, identify the serialization point or explain conflict resolution. For durability, identify acknowledgment, persistent copies, and recovery.

Guarantees compose only when boundaries align. TCP delivery does not mean database commit; broker acknowledgment does not mean consumer effect; replica count does not mean backup. A staff answer repeatedly asks where one guarantee ends and the next begins.

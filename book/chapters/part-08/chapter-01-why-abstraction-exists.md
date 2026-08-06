## 8.1 - Why Abstraction Exists {#chapter-08-01}

Abstraction is selective ignorance: it exposes the properties a caller needs while hiding choices the caller should not depend on. A good abstraction lowers the number of facts required to make a safe change. A bad one hides failure, cost, or ownership that the caller must understand.

Every abstraction has a contract, implementation, and leakage surface. A collection interface may hide layout but cannot hide complexity forever. An RPC stub may hide serialization but must not hide deadlines and partial failure. The right boundary follows a stable reason to change and preserves the operational facts that cross it.

Use abstractions to encode policy, not merely to rename mechanics. `PaymentAuthorizer` is useful when it states domain outcomes and idempotency; `PaymentManagerHelper` often just adds indirection. Evaluate an abstraction by the changes it localizes, invalid states it prevents, tests it enables, and performance/failure information it preserves.

::: {.gotcha}
**Gotcha**

“Implementation detail” is not a permanent label. If latency, consistency, resource ownership, or error behavior affects callers, it belongs in the contract even if the algorithm does not.
:::

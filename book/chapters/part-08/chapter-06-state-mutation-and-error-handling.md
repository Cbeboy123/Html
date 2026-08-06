## 8.6 - State, Mutation, and Error Handling {#chapter-08-06}

Mutable state is where time enters a program. If many components can change the same data, reasoning requires knowing every possible order. Reduce the mutation surface, make transitions explicit, and keep one owner for each invariant.

Immutability simplifies sharing and rollback but can increase allocation or copying. Persistent data structures and copy-on-write trade memory for safer versions. Local mutation inside an encapsulated operation is often clearer than a globally immutable design with accidental complexity.

Errors need a taxonomy. Domain rejections, invalid input, transient dependency failures, resource exhaustion, bugs, and cancellation demand different handling. Preserve the causal chain while translating infrastructure errors into stable boundary semantics. Never retry an unknown failure without an idempotency and budget analysis.

Exceptions work for nonlocal propagation; result types make expected alternatives visible. Either can be abused. Do not catch an error merely to log and rethrow at every layer, and do not turn programmer defects into ordinary business results.

Resource ownership must survive failure: use structured cleanup, bounded concurrency, cancellation propagation, and transactions/compensation where state spans boundaries.

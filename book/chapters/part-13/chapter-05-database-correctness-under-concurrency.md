## 13.5 - Database Correctness Under Concurrency {#chapter-13-05}

A database transaction is valuable because the database can arbitrate concurrent writers close to the authoritative state. Correctness still depends on choosing the right constraint and isolation behavior.

### Start with the invariant

An invariant is a rule that must remain true, for example:

- an email is unique within a tenant;
- an account balance cannot cross a defined limit;
- at least one doctor remains on call;
- one seat cannot be sold twice;
- an order total equals its valid lines under the business rules.

Put simple invariants in database constraints. Application validation is still useful for a clear message, but it cannot arbitrate two writers that both passed an earlier read.

### Isolation levels are sets of allowed histories

Do not learn isolation as a ladder of vague “strength.” Ask which concurrent history is allowed.

| Phenomenon | Plain meaning |
|---|---|
| Dirty read | Read data written by a transaction that has not committed |
| Non-repeatable read | Re-read one row and see a later committed value |
| Phantom | Repeat a predicate query and see a changed matching set |
| Lost update | One writer silently overwrites another writer's change |
| Write skew | Writers read a shared condition, change different rows, and jointly break it |
| Serialization anomaly | The committed result cannot match any one-at-a-time order |

Product names do not map identically. PostgreSQL 18, for example, implements Read Uncommitted like Read Committed; its Repeatable Read uses snapshot isolation and can still allow serialization anomalies; Serializable adds checks and can abort a transaction that must be retried. Other databases use different mechanisms.

### A write-skew timeline

Assume Alice and Bob are the only doctors on call. The rule says at least one must remain.

~~~text
Transaction A                         Transaction B
read Alice=on, Bob=on                 read Alice=on, Bob=on
set Alice=off                         set Bob=off
commit                               commit
~~~

The transactions update different rows, so a simple row-write conflict may not occur. Both individually saw that another doctor was on call. Together they break the invariant.

Ways to protect it include a serializable transaction with retry, a lock on a shared schedule row or predicate under product rules, or a model where the invariant is represented by a directly constrained value. The best choice depends on contention and the database.

::: {.fact}
**Worth Knowing - Serializable can mean “retry,” not “wait”**

Some databases detect that concurrent transactions cannot both fit a serial order and abort one. The application must retry the whole transaction from the beginning. A retry loop belongs around the complete transaction and still needs an overall deadline.
:::

### MVCC does not remove conflicts

Multi-version concurrency control lets readers select versions from a snapshot while writers create new versions. It reduces many reader-writer blocks. It does not make every history serializable, prevent all write conflicts, or remove cleanup.

Long transactions keep old versions potentially visible. That increases storage and cleanup work. “Idle in transaction” is therefore an operational smell even when the transaction performs no CPU work.

### Commit, WAL, and ambiguous acknowledgment

A write-ahead log records recovery information before corresponding dirty data pages are allowed to reach durable storage under the engine's protocol. Commit normally does not require every changed table page to be flushed immediately.

After a crash, recovery uses the log and data files to restore the effects that should be present and remove or ignore incomplete work. The exact redo/undo method is product-specific.

If the database commits and the network fails before the client receives success, the outcome is ambiguous. Retrying a business operation can duplicate it. Use a business operation ID, status lookup, or reconciliation even though the database transaction itself is atomic.

### Read an execution plan as a flow of rows

When a query is slow, begin with:

1. actual rows entering and leaving each operator;
2. estimated rows at those operators;
3. chosen access path and join order;
4. loops, memory, spills, I/O, locks, and client transfer;
5. parameter and data distribution for the slow case.

One large cardinality error can make the optimizer choose a join, memory grant, or access path suitable for a much smaller result. “Add an index” is not a diagnosis.

An index is valuable when it cheaply narrows or orders the required data. It also consumes space, cache, maintenance work, and write I/O. A query returning much of a table may be faster with a sequential scan.

::: {.fact}
**Product-Specific Fact - PostgreSQL sequences can have gaps**

In PostgreSQL, changes to a sequence are visible immediately and are not rolled back when the transaction aborts. A sequence is an identifier generator, not a promise of gap-free business numbering. If a law or business process requires gap-free numbers, design that requirement explicitly and accept its coordination cost.
:::

### Database decision checklist

- What is the authoritative invariant?
- Can a constraint express it directly?
- Which concurrent history must be impossible?
- What isolation or explicit lock prevents that history in this product/version?
- Which errors require whole-transaction retry?
- What is the idempotency plan after an ambiguous commit response?
- Which plan rows and waits explain performance?
- What are backup, restore, RPO, and RTO tests?

::: {.interview-tip}
**Staff-Level Answer**

Show a two-transaction schedule. Point to the constraint, lock, or serialization check that breaks the unsafe schedule. Then cover retry and ambiguous commit.
:::


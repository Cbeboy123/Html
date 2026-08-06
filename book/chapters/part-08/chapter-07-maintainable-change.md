## 8.7 - Maintainable Change {#chapter-08-07}

Maintainability is the ability to change behavior safely at an acceptable cost. It emerges from clear contracts, localized decisions, fast feedback, observable production behavior, and a codebase whose structure matches ownership.

Before changing code, identify the invariant and all readers/writers of the affected state. Make the change in a compatibility sequence when deployments are independent. Tests should pin behavior, not implementation trivia. Logs, metrics, and traces should reveal rollout impact.

Technical debt is a future change tax, not “code I dislike.” Record the constrained change, recurring cost, risk, and a trigger for repayment. Some duplication is cheaper than premature unification; merge it when the duplicated concepts change for the same reason.

A staff engineer improves the change system: simpler paved roads, dependency rules, automated migrations, safe defaults, ownership maps, and removal of obsolete paths. The goal is not architectural purity but sustained delivery without accumulating hidden operational risk.

::: {.interview-tip}
**Interview Tip**

Describe how the design behaves under the next likely change, partial rollout, failure, and rollback. That is more revealing than naming patterns.
:::

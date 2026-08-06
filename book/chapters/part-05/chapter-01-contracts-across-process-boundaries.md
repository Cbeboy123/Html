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

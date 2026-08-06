## 11.1 - Testing as Risk Control {#chapter-11-01}

Testing buys evidence against a risk; it does not prove absence of defects. Start from failure impact and choose the cheapest test that can detect the relevant mistake with trustworthy feedback.

Unit tests isolate deterministic policy and edge cases. Integration tests exercise real boundaries such as SQL, serialization, queues, clocks, and files. Contract tests validate independently deployed peers. End-to-end tests protect a few critical journeys but are slower and harder to diagnose. Property-based tests explore invariants across generated inputs; fuzzing targets parsers and unsafe state spaces; load and resilience tests reveal capacity and failure behavior.

The familiar test pyramid is an economic model, not a quota. A data-access library may need more integration evidence than isolated mocks. Test doubles should replace slow or uncontrollable boundaries, not reimplement the component being tested.

Control nondeterminism: injectable clocks/randomness, isolated data, explicit waits on conditions, and hermetic dependencies. Quarantining flaky tests without ownership creates a false-green system. Track detection rate, runtime, flake rate, and escaped defect themes; delete tests that assert irrelevant implementation details.

::: {.interview-tip}
**Interview Tip**

For each test layer, name the risk it catches and the failure it cannot catch.
:::

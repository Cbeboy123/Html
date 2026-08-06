## 8.5 - SOLID as Diagnostic Heuristics {#chapter-08-05}

SOLID is most useful as a set of questions, not laws.

| Heuristic | Diagnostic question |
|---|---|
| Single responsibility | Which actor or policy gives this module a reason to change? |
| Open/closed | Can a likely variant be added without rewriting stable policy? |
| Liskov substitution | Does every subtype preserve the promised preconditions, postconditions, and invariants? |
| Interface segregation | Is each client forced to depend on operations it does not use? |
| Dependency inversion | Does stable policy depend on volatile mechanism, or the reverse? |

Applying every rule mechanically produces interface inflation, speculative extension points, and behavior scattered across files. A two-case conditional may be clearer than a plugin architecture. “Single responsibility” is not “one method”; a cohesive module can coordinate several steps of one policy.

Use SOLID after identifying actual change pressure and pain. Name the violated contract, show the coupled change, and propose the smallest boundary that localizes it. Then include runtime and data architecture: object-level elegance does not compensate for a shared database or synchronous dependency chain.

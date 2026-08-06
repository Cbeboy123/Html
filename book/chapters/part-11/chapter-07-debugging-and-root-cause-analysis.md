## 11.7 - Debugging and Root Cause Analysis {#chapter-11-07}

Debugging is hypothesis refinement. First preserve facts: impact, start time, scope, recent changes, exact errors, and relevant telemetry. Build a timeline with source clocks identified. Then localize the first boundary where expected evidence diverges.

Use comparisons: healthy versus failing tenant, host, region, version, request, or time window. Change one variable when practical. Reproduction is valuable, but production-only failures can still be diagnosed from invariants, traces, dumps, profiles, and controlled experiments.

Correlation is not causation; neither is the last deployment automatically guilty. A root cause should explain the mechanism, affected scope, timing, and why defenses failed. “Human error” stops too early—ask why the action was easy, unchecked, and broad.

Distinguish trigger, contributing conditions, and latent control gaps. Corrective actions should reduce recurrence or blast radius and have owners and verification. Avoid sprawling action lists that cannot be completed.

::: {.interview-tip}
**Interview Tip**

Say what observation would falsify your leading hypothesis. That demonstrates disciplined diagnosis.
:::

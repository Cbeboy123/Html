<!-- FILE: book/chapters/part-11/chapter-01-testing-as-risk-control.md -->
## 11.1 - Testing as Risk Control {#chapter-11-01}

Testing buys evidence against a risk; it does not prove absence of defects. Start from failure impact and choose the cheapest test that can detect the relevant mistake with trustworthy feedback.

Unit tests isolate deterministic policy and edge cases. Integration tests exercise real boundaries such as SQL, serialization, queues, clocks, and files. Contract tests validate independently deployed peers. End-to-end tests protect a few critical journeys but are slower and harder to diagnose. Property-based tests explore invariants across generated inputs; fuzzing targets parsers and unsafe state spaces; load and resilience tests reveal capacity and failure behavior.

The familiar test pyramid is an economic model, not a quota. A data-access library may need more integration evidence than isolated mocks. Test doubles should replace slow or uncontrollable boundaries, not reimplement the component being tested.

Control nondeterminism: injectable clocks/randomness, isolated data, explicit waits on conditions, and hermetic dependencies. Quarantining flaky tests without ownership creates a false-green system. Track detection rate, runtime, flake rate, and escaped defect themes; delete tests that assert irrelevant implementation details.

::: {.interview-tip}
**Interview Tip**

For each test layer, name the risk it catches and the failure it cannot catch.
:::

<!-- FILE: book/chapters/part-11/chapter-02-continuous-integration-and-delivery.md -->
## 11.2 - Continuous Integration and Delivery {#chapter-11-02}

Continuous integration means small changes merged frequently into a shared, releasable line with automated feedback. Continuous delivery keeps every validated revision deployable; continuous deployment automatically releases it. These are operating disciplines, not a particular server.

A strong pipeline is fast, deterministic, observable, and produces one immutable artifact promoted across environments. Stages commonly include source policy, compilation, unit/static/security checks, integration/contract tests, artifact attestation, deployment, and post-deploy verification. Environment-specific configuration is supplied at deploy time; rebuilding per environment destroys provenance.

Parallelize independent checks and run the fastest high-signal gates early. Cache carefully: a poisoned or incorrectly keyed cache can produce false success. Protect credentials, isolate untrusted pull-request code, pin toolchains, and preserve audit trails.

Database and contract changes must tolerate mixed versions. A green pipeline cannot compensate for an unsafe rollout. Measure lead time, deployment frequency, change failure rate, recovery time, queue time, and flaky-test burden to improve flow without gaming counts.

<!-- FILE: book/chapters/part-11/chapter-03-safe-production-change.md -->
## 11.3 - Safe Production Change {#chapter-11-03}

Reduce change risk through small scope, staged exposure, fast detection, and a tested recovery path. A deployment installs code; a release exposes behavior. Feature flags can separate them, while canaries and progressive delivery compare a small population before broad rollout.

Define health before starting: user outcomes, error rate, latency, saturation, and domain invariants. Automated rollback helps only for reversible code/configuration. Database writes, external effects, and data migrations may require roll-forward or compensation.

Use expand-and-contract for schemas and protocols. Shadow traffic can compare behavior but must prevent duplicate effects and protect sensitive data. Blue/green reduces replacement time but doubles some capacity and complicates stateful compatibility.

Configuration is production code: validate types and ranges, review changes, stage them, record provenance, and bound dynamic updates. A kill switch needs ownership, authentication, observability, and regular testing.

::: {.gotcha}
**Gotcha**

“Rollback” is not a plan until you state what happens to data written by the new version and clients that adopted the new contract.
:::

<!-- FILE: book/chapters/part-11/chapter-04-observability.md -->
## 11.4 - Observability {#chapter-11-04}

Observability is the ability to infer internal state from emitted evidence. Logs describe discrete events, metrics summarize numeric behavior, and traces connect work across boundaries. None is universally superior.

Instrument from questions: can we locate a failed request, distinguish queueing from service time, identify the dependency, measure user impact, and verify a rollout? Use structured events, stable semantic fields, correlation/trace context, and carefully controlled cardinality. Never log secrets; treat telemetry as sensitive production data.

Metrics need units, aggregation, and distribution. Averages conceal tails; percentiles cannot always be aggregated across arbitrary precomputed windows. Traces require propagation, sampling, and span boundaries that reflect actual waits. Logs need retention and indexes based on incident queries.

Telemetry has cost and failure modes. Bound buffers, drop safely under pressure, record dropped-data signals, and avoid making the application depend synchronously on the collector. Sampling must retain rare errors and high-latency exemplars where possible.

::: {.interview-tip}
**Interview Tip**

Start with a diagnostic question and show which signal answers it. “Add logs and dashboards” is not an observability design.
:::

<!-- FILE: book/chapters/part-11/chapter-05-service-health.md -->
## 11.5 - Service Health {#chapter-11-05}

SLIs measure user-visible behavior, SLOs set target levels, and SLAs are external commitments with defined consequences. Good SLIs measure successful, sufficiently fast, correct operations at the boundary users care about.

Availability ratios require a valid denominator. For request services, count eligible requests; for batch systems, measure completion by deadline; for pipelines, measure freshness and correctness. Exclude traffic only by an explicit policy that cannot hide failure.

An error budget is the allowed unreliability implied by the SLO. Burn-rate alerts detect consumption fast enough to act while avoiding noise from insignificant blips. Combine a fast, high-burn window with a slower confirmation window.

Health endpoints have different purposes. Liveness asks whether restart may help. Readiness asks whether to route traffic. Startup protects slow initialization. A dependency outage should not necessarily fail liveness and create a fleet restart storm.

Capacity signals—utilization, saturation, queueing, headroom, and forecast—complement outcome SLIs. Report SLOs by critical journey and tenant where aggregation would hide harm.

<!-- FILE: book/chapters/part-11/chapter-06-performance-engineering.md -->
## 11.6 - Performance Engineering {#chapter-11-06}

Performance work begins with a target, workload, and constraint. Latency, throughput, utilization, cost, and correctness interact. Optimize the bottleneck only after measuring it under representative data and concurrency.

Build a latency budget across queues and service time. Use profiles for CPU and allocation, traces for distributed waits, database plans for data access, and system counters for scheduler, memory, network, and storage. Coordinated omission in load generation can hide the worst latency by pausing requests when the system is slow.

Little’s Law explains that in-flight work grows with throughput times latency. Queueing theory explains the nonlinear rise near saturation. Control concurrency before saturation, then improve service time through better algorithms, locality, batching, reduced copying, efficient I/O, and fewer remote round trips.

Benchmark warm-up and steady state separately; record hardware, runtime, dataset, compiler, configuration, and statistical uncertainty. Compare distributions and resource use, not one average. A faster component can make the system worse if it shifts load onto a constrained dependency.

<!-- FILE: book/chapters/part-11/chapter-07-debugging-and-root-cause-analysis.md -->
## 11.7 - Debugging and Root Cause Analysis {#chapter-11-07}

Debugging is hypothesis refinement. First preserve facts: impact, start time, scope, recent changes, exact errors, and relevant telemetry. Build a timeline with source clocks identified. Then localize the first boundary where expected evidence diverges.

Use comparisons: healthy versus failing tenant, host, region, version, request, or time window. Change one variable when practical. Reproduction is valuable, but production-only failures can still be diagnosed from invariants, traces, dumps, profiles, and controlled experiments.

Correlation is not causation; neither is the last deployment automatically guilty. A root cause should explain the mechanism, affected scope, timing, and why defenses failed. “Human error” stops too early—ask why the action was easy, unchecked, and broad.

Distinguish trigger, contributing conditions, and latent control gaps. Corrective actions should reduce recurrence or blast radius and have owners and verification. Avoid sprawling action lists that cannot be completed.

::: {.interview-tip}
**Interview Tip**

Say what observation would falsify your leading hypothesis. That demonstrates disciplined diagnosis.
:::

<!-- FILE: book/chapters/part-11/chapter-08-incidents-and-recovery.md -->
## 11.8 - Incidents and Recovery {#chapter-11-08}

During an incident, establish command, technical leads, communications, and a shared log. The priority is user safety and restoration, not proving cause. Stabilize with reversible actions: stop a rollout, shed load, disable an optional path, fail over when tested, or restore capacity.

Declare impact and working hypotheses explicitly. Time-box experiments and record result, owner, and next decision. Communicate what is known, unknown, affected, being done, and when the next update will arrive. Avoid confident speculation.

Recovery includes data integrity, backlogs, caches, reconciliation, and returning temporary controls to normal. Monitor after apparent restoration. Preserve evidence before destructive cleanup.

A blameless review reconstructs how the system made actions reasonable, identifies technical and organizational contributors, and produces a small set of high-leverage improvements. Track them to verification. Share durable learning without exposing sensitive details.

Practice through game days and restore drills. An unread runbook and an untested backup are hypotheses, not capabilities.

<!-- FILE: book/chapters/part-11/chapter-09-from-senior-to-staff.md -->
## 11.9 - From Senior to Staff {#chapter-11-09}

Senior engineers reliably solve difficult problems within a team. Staff engineers increase the organization’s ability to solve classes of problems across boundaries. The shift is from personal output to durable leverage, without abandoning technical depth.

Staff work frames ambiguous problems, names constraints and non-goals, aligns stakeholders, finds the smallest coherent strategy, and creates mechanisms others can operate. Influence comes from evidence, clear writing, prototypes, teaching, and trust—not title or architectural veto.

Choose work where cross-team coordination, systemic risk, or long time horizons justify the role. Make decisions reversible where possible, document tradeoffs, invite dissent, and define success measures. Delegate ownership genuinely; becoming the mandatory reviewer for everything is negative leverage.

Technical strategy connects business outcomes to architecture, migration sequence, investment, and operations. It includes deleting systems, standardizing paved roads, paying down recurring risk, and knowing when local diversity is cheaper than centralization.

::: {.interview-tip}
**Interview Tip**

Tell a story with scope, competing constraints, your reasoning, how others gained ownership, measurable outcome, and what you changed after learning—not merely a heroic implementation.
:::

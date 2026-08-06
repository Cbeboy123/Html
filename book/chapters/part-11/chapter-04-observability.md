## 11.4 - Observability {#chapter-11-04}

Observability is the ability to infer internal state from emitted evidence. Logs describe discrete events, metrics summarize numeric behavior, and traces connect work across boundaries. None is universally superior.

Instrument from questions: can we locate a failed request, distinguish queueing from service time, identify the dependency, measure user impact, and verify a rollout? Use structured events, stable semantic fields, correlation/trace context, and carefully controlled cardinality. Never log secrets; treat telemetry as sensitive production data.

Metrics need units, aggregation, and distribution. Averages conceal tails; percentiles cannot always be aggregated across arbitrary precomputed windows. Traces require propagation, sampling, and span boundaries that reflect actual waits. Logs need retention and indexes based on incident queries.

Telemetry has cost and failure modes. Bound buffers, drop safely under pressure, record dropped-data signals, and avoid making the application depend synchronously on the collector. Sampling must retain rare errors and high-latency exemplars where possible.

::: {.interview-tip}
**Interview Tip**

Start with a diagnostic question and show which signal answers it. “Add logs and dashboards” is not an observability design.
:::

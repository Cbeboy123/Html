## 9.8 - Backpressure and Overload Control {#chapter-09-08}

When arrival rate exceeds sustainable completion rate, queues grow. Little’s Law (`L = λW`) relates average in-flight work, throughput, and time in a stable system. Once saturated, adding queue capacity usually converts rejection into worse latency and memory pressure.

Backpressure communicates limited capacity upstream. Techniques include bounded queues, concurrency limits, rate limits, pull-based flow, credit windows, and explicit overload responses. Admission should occur before expensive work and distinguish tenants or priorities where business policy requires it.

Load shedding preserves useful service by rejecting work unlikely to finish before its deadline. Circuit breakers stop repeated calls to a failing dependency; they require a meaningful fallback and cautious probing. Bulkheads isolate resources so one workload cannot exhaust all pools.

Adaptive concurrency can use observed queueing or latency, but feedback loops can oscillate. Bound them and test under bursts, slow dependencies, retry storms, and recovery. Autoscaling is slower than an overload event and needs headroom; it complements rather than replaces admission control.

::: {.interview-tip}
**Interview Tip**

Trace where work waits and who owns the queue. “Add a message queue” does not remove overload; it relocates and buffers it.
:::

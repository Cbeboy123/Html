## 11.6 - Performance Engineering {#chapter-11-06}

Performance work begins with a target, workload, and constraint. Latency, throughput, utilization, cost, and correctness interact. Optimize the bottleneck only after measuring it under representative data and concurrency.

Build a latency budget across queues and service time. Use profiles for CPU and allocation, traces for distributed waits, database plans for data access, and system counters for scheduler, memory, network, and storage. Coordinated omission in load generation can hide the worst latency by pausing requests when the system is slow.

Little’s Law explains that in-flight work grows with throughput times latency. Queueing theory explains the nonlinear rise near saturation. Control concurrency before saturation, then improve service time through better algorithms, locality, batching, reduced copying, efficient I/O, and fewer remote round trips.

Benchmark warm-up and steady state separately; record hardware, runtime, dataset, compiler, configuration, and statistical uncertainty. Compare distributions and resource use, not one average. A faster component can make the system worse if it shifts load onto a constrained dependency.

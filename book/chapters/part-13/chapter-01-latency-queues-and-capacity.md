## 13.1 - Latency, Queues, and Capacity {#chapter-13-01}

A system can be fast when nearly idle and unusable when busy even though no code changed. The missing idea is **queueing**. Work waits whenever demand temporarily arrives faster than a resource can finish it. The resource may be a CPU core, thread pool, connection pool, disk, broker partition, database lock, or downstream service.

### The four numbers to keep separate

- **Service time** is time actively spent by the resource on one item.
- **Queue time** is time the item waits before service begins.
- **Response time** is queue time plus service time and other boundary costs.
- **Throughput** is completed items per unit of time.

If a database query uses 20 ms of database time but waits 180 ms for a connection, making the query twice as fast can save at most 10 ms. The right first fix is usually at the connection-pool or workload boundary.

### A small capacity example

Suppose one worker completes a request in 50 ms when it has all resources. One worker can therefore complete at most about 20 requests per second:

`1 second / 0.05 second = 20 requests per second`

Ten independent workers have a simple upper bound near 200 requests per second. This is not a safe operating target. Real requests vary, workers pause, dependencies compete, and bursts arrive. If normal traffic is already 195 requests per second, there is almost no headroom. A brief burst creates a queue that may take a long time to drain.

**Utilization** is the fraction of capacity in use. As utilization approaches 100%, small variations cause queue time to rise sharply. This is why average CPU of 70% can coexist with a saturated single core, hot partition, or connection pool. Measure the limiting resource, not only a machine-wide average.

### Little's Law as a practical check

For a stable system, Little's Law says:

`average in-flight work = average throughput × average time in the system`

If a service completes 500 requests per second and requests spend 0.2 seconds in the service, about 100 requests are in flight on average. If dashboards show 2,000 in flight at the same throughput, response time is closer to four seconds or the measurements do not describe the same boundary.

Little's Law does not predict a safe queue size. It checks whether throughput, time, and in-flight work agree over the same stable interval.

::: {.fact}
**Surprising Fact - Fan-out magnifies tail latency**

Assume each of 50 independent downstream calls has a 1% chance of being slow. The chance that at least one call is slow is `1 - 0.99^50`, about 39.5%. A small tail problem at one hop can become common at the top-level request. The independence assumption is simplified; shared overload often makes the real correlation worse.
:::

### Build a latency budget

For a 300 ms user deadline, do not give every dependency a 300 ms timeout. Reserve time for admission, application work, response transfer, and failure handling. One possible starting budget is:

| Stage | Budget | Evidence |
|---|---:|---|
| Edge and admission | 20 ms | Edge timing, limiter decision |
| Application queue | 30 ms | Queue histogram |
| Application CPU/work | 50 ms | Profile and span |
| Database | 100 ms | Pool wait plus query span |
| Other dependency | 50 ms | Client and server spans |
| Response and safety margin | 50 ms | End-to-end client timing |

The numbers are an example, not defaults. The important rule is that inner work receives the caller's **remaining deadline**. An outer layer needs enough time to stop, record the failure, and return a useful result.

### A safe overload sequence

1. Measure the user outcome: success, latency distribution, and correctness.
2. Find the first growing queue or saturated resource.
3. Bound admission before expensive work begins.
4. Bound concurrency at each scarce dependency.
5. Reject work that cannot finish before its deadline.
6. Use retry budgets, backoff, and jitter so failure does not multiply traffic.
7. Add capacity only after confirming the bottleneck and recovery behavior.

An unbounded queue is delayed failure. It consumes memory, makes cancellation less useful, and returns stale results long after callers have left. A bounded queue turns overload into an explicit decision.

::: {.interview-tip}
**Staff-Level Answer**

Name the queue, owner, maximum size, admission rule, deadline, and recovery signal. “Autoscale the service” is incomplete because scaling often arrives after the overload and may move pressure to the database.
:::


## 2.10 - Practical Linux and Isolation {#chapter-02-10}

Production diagnosis improves when each command answers a question. Running a
large command checklist without a hypothesis produces snapshots, not evidence.

| Question | Useful Linux surface |
|---|---|
| Which processes or threads consume CPU? | `ps`, `top`, scheduler/proc counters |
| Which files or sockets are open? | `lsof`, `/proc/<pid>/fd` |
| Which system calls block or fail? | `strace` where permitted |
| What memory is mapped or resident? | `/proc/<pid>/maps`, `smaps`, process counters |
| Which signal ended the process? | supervisor/kernel logs and exit status |

`/proc` is a kernel-provided view whose fields and availability depend on the
Linux version and permissions. `strace` observes the system-call boundary; it
can alter timing and adds overhead, so use it deliberately.

A **signal** is an asynchronous notification delivered under OS rules. Graceful
shutdown code must stop accepting work, drain or cancel bounded in-flight work,
flush state that must be durable, and exit before the supervisor’s deadline.
Not every termination can be intercepted.

Containers build isolation from kernel mechanisms. **Namespaces** give processes
separate views of resources such as process IDs, mounts, or networking.
**cgroups** account for and limit resources. A container shares the host kernel;
it is not the same isolation boundary as a virtual machine with a separate
guest kernel.

Limits are part of behavior. CPU quotas can cause throttling; memory limits can
trigger reclamation or termination; descriptor and process limits can reject
new work. Application metrics may look healthy if they omit the cgroup and host
boundary.

::: {.scenario}
**Real-World Scenario**

Imagine a service showing low average CPU but periodic latency spikes. Cgroup
throttling counters align with the spikes. Adding application threads would
increase contention; the useful next question concerns quota and burst shape.
:::

::: {.interview-tip}
**Interview Tip**

State the hypothesis before the command: “I suspect descriptor exhaustion, so I
will compare open descriptors with the process limit and identify their types.”
:::

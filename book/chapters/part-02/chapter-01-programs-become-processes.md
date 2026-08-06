## 2.1 - Programs Become Processes {#chapter-02-01}

A program on disk is passive. A **process** (a running program with an isolated
virtual address space and operating-system-managed resources) is what the
operating system schedules and protects.

Applications normally execute in **user mode**, where privileged hardware
operations are restricted. The kernel runs in a privileged mode and exposes
**system calls**: controlled entry points for operations such as opening a file,
creating a process, mapping memory, or using a socket. A system call crosses a
protection boundary; it is not identical to an ordinary function call.

A process owns or refers to resources including virtual-memory mappings, open
file descriptors, credentials, signal dispositions, and an environment.
Processes can share resources deliberately, but isolation is the default
reasoning model. A crash usually destroys the process’s volatile state while
leaving kernel-managed and external effects subject to their own lifecycle.

~~~mermaid
flowchart TB
    app[Application in user mode] -->|system call| kernel[Kernel]
    kernel --> scheduler[Scheduler]
    kernel --> memory[Virtual memory manager]
    kernel --> io[I/O subsystem]
    io --> device([Device or network])
~~~

*Diagram key: rectangles are active software components; the rounded box is an
external device or network. Solid arrows are control transfers or requests.*

A **file descriptor** is a process-local handle referring to a kernel-managed
open resource. It may represent a regular file, pipe, socket, or device.
Descriptors can leak just as heap objects can; exhaustion appears as failed
opens or connections even when memory is available.

Creation and replacement semantics vary across operating systems. On Unix-like
systems, process creation and program replacement are separate concepts, and
inherited descriptors require careful close-on-exec policy. Treat exact APIs as
platform-specific.

::: {.interview-tip}
**Interview Tip**

Explain protection and ownership, not merely “a process is a program in
execution.” Mention system calls, virtual address spaces, descriptors, and what
must be cleaned up on failure.
:::

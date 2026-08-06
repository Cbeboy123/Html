## 2.9 - Files, I/O, and Durability {#chapter-02-09}

A successful write call does not always mean bytes survive power loss. Several
buffers and devices may sit between application memory and durable media.

A **file system** maps names and directories to stored data and metadata. The
operating system’s **page cache** keeps file-backed pages in memory. Buffered
writes may return after copying data into memory, with persistence occurring
later. A flush/synchronization operation requests stronger ordering or
durability, but exact guarantees depend on the OS, file system, device, and
application protocol.

~~~mermaid
flowchart LR
    app[Application buffer] -->|write| cache[OS page cache]
    cache -.->|write-back| device[Device controller]
    device ==> media[(Persistent media)]
    app -->|sync request| cache
~~~

*Diagram key: rectangles are active buffering/I/O stages; cylinder is persistent
media; dashed arrow is deferred write-back; thick arrow is the persistence path.*

**Blocking I/O** can suspend the calling thread until progress or completion.
Non-blocking I/O returns when an operation would wait. Readiness APIs report
which descriptors may make progress; asynchronous completion APIs report later
completion. Names and exact behavior vary by platform.

Files are byte sequences, while record boundaries belong to a format. Partial
reads and writes are normal for many APIs. Correct code loops until the intended
amount is processed or a terminal condition occurs.

Crash-safe updates often require a protocol: write new data, make required bytes
durable, atomically switch a reference where supported, and make directory
metadata durable when the platform requires it. “Rename is atomic” is
insufficient without defining scope, file system, and durability.

::: {.interview-tip}
**Interview Tip**

Separate visibility from durability. Another process reading new bytes does not
prove those bytes will survive a crash.
:::

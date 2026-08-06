## 2.5 - Virtual Memory {#chapter-02-05}

Two processes both use the same numeric address without corrupting each other.
**Virtual memory** gives each process an address space that the operating system
and hardware translate to physical memory or other backing.

~~~mermaid
flowchart LR
    cpu[CPU issues virtual address] --> tlb{TLB entry?}
    tlb -->|hit| physical[Physical frame]
    tlb -->|miss| walk[Page-table walk]
    walk --> present{Page present?}
    present -->|yes| physical
    present -->|no| fault[Page fault handler]
    fault --> backing[(File or swap backing)]
    backing -->|load page| physical
~~~

*Diagram key: rectangles are active translation/handling steps; diamonds are
conditions; the cylinder is persistent backing. Solid arrows show address
translation and page loading.*

A **page** is a fixed-size virtual-memory unit; a **frame** is the corresponding
physical-memory unit. Page tables store mappings and permissions. A
**translation lookaside buffer** (TLB) caches recent translations.

A page fault is not inherently an error. It can allocate a zero-filled page,
load file-backed data, implement copy-on-write, or signal invalid access. A
major fault requiring storage work is much costlier than a mapping resolved in
memory, but exact terminology and counters vary by OS.

Paging enables isolation, sparse address spaces, shared libraries, memory-mapped
files, and controlled overcommit. It also creates failure modes: memory pressure,
thrashing, unexpected copy-on-write costs, and out-of-memory termination.
**Thrashing** is repeated movement of working data because active demand exceeds
available memory.

Segmentation historically used variable-sized logical regions; modern
general-purpose systems rely primarily on paging, though architectural details
vary.

::: {.interview-tip}
**Interview Tip**

Distinguish virtual address space, resident physical memory, and durable backing.
“The process allocated 8 GB” does not by itself say 8 GB is resident.
:::

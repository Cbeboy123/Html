# Visual Notation Used Throughout the Book {.unnumbered}

Every diagram uses the same semantic shapes and line meanings. Shape and line
style—not color—carry information, so the diagrams remain readable on a
black-and-white laser printer.

~~~mermaid
flowchart LR
    actor([External actor])
    process[Active process]
    store[(Persistent data)]
    channel{{Async channel}}
    choice{Decision}
    actor -->|direct call| process
    process -.->|message later| channel
    process ==>|replicate or stream| store
    process --x choice
~~~

*Diagram key: rounded box = external actor or independently operated system;
rectangle = active process or service; cylinder = persistent datastore; hexagon
= asynchronous queue, topic, or log; diamond = decision or condition. Solid
arrow = direct request, data, or control flow; dashed arrow = asynchronous or
deferred flow; thick arrow = replication or sustained stream; cross-ended arrow
= blocked or failed path (the surrounding text names the cause).*

## Master symbol key {.unnumbered}

| Visual form | Meaning | Usage rule |
|---|---|---|
| Rounded box | External actor or independently operated system | Use for a person, client, or system outside the diagram’s main boundary. |
| Rectangle | Active component or process | Use for code that performs work. |
| Cylinder | Persistent datastore | Use only when data is intended to survive the active process. |
| Hexagon | Asynchronous channel | Use for a queue, event stream, topic, or log. |
| Diamond | Decision or condition | Label outgoing paths with the actual outcomes. |
| Dashed subgraph border | Trust, deployment, ownership, or failure boundary | Name the kind of boundary. |
| Solid arrow | Direct request, data movement, or control transfer | Direction must match the real flow. |
| Dashed arrow | Asynchronous, deferred, or independently consumed flow | Not for ordinary responses. |
| Thick arrow | Replication or sustained/bulk stream | Use sparingly and label what is copied. |
| Cross-ended arrow | Failure, rejection, blocking, or dropped flow | Label the reason. |

## Sequence-diagram notation {.unnumbered}

| Sequence mark | Meaning |
|---|---|
| Solid arrow | Request, command, or protocol flight |
| Dashed return arrow | Response or acknowledgment |
| Open asynchronous arrow | Message whose sender does not wait for completion |
| Activation bar | Time during which a participant handles the interaction |
| Note | State, validation, or timing information—not a hidden message |

Each diagram repeats a short inline key containing only the symbols it uses.

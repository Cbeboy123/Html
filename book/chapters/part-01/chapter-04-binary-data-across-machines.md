## 1.4 — Binary Data Across Machines {#chapter-01-04}

A value written on one machine is read as a wildly different value on another.
The bytes arrived intact; the two sides disagreed about their order or layout.

**Endianness** is the order in which a multi-byte value’s bytes are placed in
memory or a byte stream. In little-endian order the least-significant byte comes
first; in big-endian order the most-significant byte comes first. A protocol
must choose one order rather than inherit whatever the host happens to use.

~~~mermaid
flowchart LR
    value[32-bit value] --> encoder[Protocol encoder]
    encoder -->|defined byte order| wire{{Byte stream}}
    wire -.-> decoder[Protocol decoder]
    decoder --> value2[Equivalent value]
~~~

*Diagram key: rectangles perform active conversion; the hexagon is a transmitted
byte stream. Solid arrows show encoding; the dashed arrow marks independently
performed decoding.*

**Alignment** means placing data at addresses preferred or required by a
processor. Compilers may insert padding between structure fields. That layout is
an implementation detail unless an explicit application binary interface
defines it. Copying an in-memory structure directly onto a network connection is
therefore fragile: padding, byte order, word size, and compiler rules can differ.

A durable wire format specifies:

- field order and identifiers;
- numeric widths and signedness;
- byte order where relevant;
- text encoding;
- optional and repeated field behavior;
- framing, so a receiver can find message boundaries;
- compatibility rules for unknown or missing fields.

Checksums and cryptographic hashes can detect accidental or intentional changes,
but they do not explain the bytes. Compression reduces representation size at
the cost of CPU work and operational complexity. Encryption hides content but
still requires an agreed plaintext format.

::: {.gotcha}
**Gotcha**

“Network byte order” commonly means big-endian for traditional Internet
protocol fields. That convention does not imply that every modern protocol or
serialization format uses big-endian encoding.
:::

Failures usually appear as corrupted lengths, impossible timestamps, truncated
messages, or version incompatibility. Capture the raw bytes, identify the schema
and version, and decode one field at a time. Do not begin by blaming the network
when the byte sequence arrived unchanged.

::: {.interview-tip}
**Interview Tip**

Separate host-memory layout from the wire contract. A strong answer also mentions
schema evolution and framing; byte order alone is not interoperability.
:::


## 5.5 - Serialization Formats {#chapter-05-05}

Serialization converts structured values into bytes; deserialization reconstructs
values under a schema or interpretation. The format choice affects
interoperability, evolution, inspection, and performance.

| Format | Strength | Main caution |
|---|---|---|
| JSON | Human-readable, broad tooling | Numbers, binary data, and schema require policy |
| Protocol Buffers | Compact tagged fields and generated contracts | Field-number reuse and semantic changes break evolution |
| Avro | Schema-driven data with strong data-pipeline use | Reader/writer schema resolution must be operated correctly |

Size claims depend on data and encoding choices; benchmark representative
messages instead of repeating universal ratios. Compression can dominate format
size for large repetitive payloads.

Schema evolution works when identifiers remain stable and old/new interpretations
agree. Adding an optional field is often compatible, but changing units or
meaning is not. Removing a field from code does not make its identifier safe to
reuse.

Deserialization is a trust boundary. Bound message size, nesting, collection
counts, and resource use. Avoid formats that instantiate arbitrary application
types from untrusted input.

Text fields still need an encoding, timestamps need a timeline/offset policy,
and decimals need scale/rounding semantics. A binary schema does not remove
domain ambiguity.

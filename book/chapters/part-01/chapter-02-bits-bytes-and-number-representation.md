## 1.2 — Bits, Bytes, and Number Representation {#chapter-01-02}

A database identifier overflows only in production. Nothing in the source code
looked unusual; the stored value simply exceeded what one layer could represent.
Representation choices become correctness constraints at system boundaries.

A **bit** is a binary digit, either 0 or 1. A **byte** is the addressable group of
bits used by the platform; modern general-purpose systems conventionally use
eight-bit bytes. Binary is base 2, while hexadecimal is base 16 and provides a
compact way to display groups of bits.

| Representation | Digits | Why engineers use it |
|---|---|---|
| Binary | 0, 1 | Flags, masks, and bit-level reasoning |
| Decimal | 0–9 | Human-facing quantities |
| Hexadecimal | 0–9, A–F | Addresses, bytes, hashes, and protocol diagnostics |

An unsigned integer interprets every bit as magnitude. A signed integer needs a
rule for negative values; **two’s complement** is the dominant representation in
current general-purpose hardware. With a fixed width, arithmetic has a finite
range. Crossing it causes overflow. Whether overflow wraps, traps, saturates, or
is undefined depends on the language and operation.

The same bytes can mean different things under different schemas. A sequence
could represent an integer, encoded text, a floating-point value, or part of a
compressed payload. Bytes do not carry their own universal type.

**Bit masks** use selected bits as independent flags. The operations AND, OR,
XOR, and NOT can test, set, toggle, or clear those flags. They are useful for
compact protocol fields and permissions, but a named type is often clearer for
ordinary application code.

Common production failures include:

- narrowing a large value into a smaller integer type;
- mixing signed and unsigned comparisons;
- assuming a database, serializer, and application use the same width;
- shifting by an invalid or surprising amount;
- exposing internal numeric identifiers to JavaScript clients, whose exact
  integer behavior differs from arbitrary-width integer types;
- treating a byte count as a character count.

::: {.gotcha}
**Gotcha**

“The value is positive” does not prove it fits. Validate the allowed range at
the boundary where a wider representation becomes narrower.
:::

::: {.interview-tip}
**Interview Tip**

State that overflow behavior is language-specific. Then explain the durable
principle: fixed-width representations have bounds, and every conversion must
preserve the intended value or fail explicitly.
:::


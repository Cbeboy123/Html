## 1.3 — Text Is Not Just Characters {#chapter-01-03}

Two user names look identical on screen but compare as different strings. Another
is cut in half when a service truncates it to a byte limit. Both failures come
from treating text as an array of simple characters.

**Unicode** is a standard that assigns abstract characters and other textual
elements to numeric **code points**. A code point is commonly written as
`U+...`. An **encoding** maps those code points to bytes. UTF-8 is a
variable-length Unicode encoding that preserves ASCII byte values for the ASCII
range.

The layers are distinct:

| Layer | Example question |
|---|---|
| Bytes | What was transmitted or stored? |
| Code units | What units does this string API index? |
| Code points | Which Unicode values are present? |
| Grapheme clusters | What does a user perceive as one displayed character? |

A user-perceived character can contain more than one code point, such as a base
letter followed by a combining mark. Some emoji sequences also combine multiple
code points. Therefore byte length, code-unit length, code-point count, and
display width can all differ.

**Unicode normalization** converts canonically equivalent sequences into a
chosen normal form. It is useful where an application wants equivalent text to
compare consistently. Normalization is not a complete security policy, and it
does not make visually similar characters from different scripts identical.

At a boundary, the producer and consumer must agree on the encoding. UTF-8
decoders also need a defined policy for malformed byte sequences: reject,
replace, or otherwise handle them explicitly. Silently decoding with the
platform’s current default creates environment-dependent behavior.

Production trouble tends to appear in truncation, validation, search, and
identity:

- Truncating bytes can split an encoded code point.
- Truncating code points can split a grapheme cluster.
- Case conversion and collation depend on language and purpose.
- Database column limits may be expressed in bytes or characters depending on
  the product and type.
- File names and identifiers can have normalization or case-sensitivity rules
  that differ between systems.

::: {.scenario}
**Real-World Scenario**

Imagine a message field limited by a byte-oriented protocol. Validate the UTF-8
encoded size, but truncate at a safe text boundary before encoding. Preserve the
original input separately if the product needs lossless recovery.
:::

::: {.interview-tip}
**Interview Tip**

Say “Unicode defines characters; UTF-8 encodes code points as bytes.” Then name
the counting unit required by the problem instead of saying “string length.”
:::


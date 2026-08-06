## 3.8 - HTTP {#chapter-03-08}

HTTP defines request and response semantics above a transport. A method, target,
headers, and optional content form a request; a status, headers, and optional
content form a response.

**Safe** methods are intended not to request state change. **Idempotent** methods
are intended to have the same requested effect when repeated. These semantic
properties guide retries but cannot prevent a buggy handler or incidental
logging.

HTTP/1.1 commonly reuses connections but serializes message syntax on each
connection. HTTP/2 multiplexes streams over one connection and compresses
headers; TCP loss still affects the connection’s byte stream. HTTP/3 maps
streams onto QUIC, reducing transport-level cross-stream blocking.

Caching requires an explicit model. Freshness metadata can permit reuse without
contacting the origin. A validator such as an ETag enables a conditional request
and a “not modified” response. `Vary` makes selected request headers part of the
cache key. Shared and private caches have different authorization and privacy
concerns.

Cookies are name/value state selected by domain/path and policy attributes, then
sent with matching requests. Secure, HttpOnly, and SameSite attributes address
different threats; none replaces server-side authorization.

Status codes describe the HTTP result, not necessarily the complete business
outcome. A timeout after sending a request creates an ambiguous result: the
server may have committed it even though no response arrived.

::: {.interview-tip}
**Interview Tip**

Tie retries to method semantics, idempotency controls, and ambiguous outcomes.
Do not say “GET always succeeds” or “POST can never be retried.”
:::

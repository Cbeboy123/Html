## 5.2 - Resource-Oriented HTTP APIs {#chapter-05-02}

REST is an architectural style with constraints including a uniform interface,
stateless requests, cacheability, and layered components. An endpoint returning
JSON over HTTP is not automatically RESTful.

HTTP method semantics matter. GET is safe and idempotent by intent. PUT requests
a selected resource state and is idempotent by intent. DELETE is idempotent in
requested effect even if later responses differ. POST has broad processing
semantics and can still be made retry-safe with an application idempotency key.

Resource identifiers should remain stable while representations evolve. Status
codes and structured error bodies serve different purposes: the code supports
generic HTTP handling; the body carries domain-specific details without leaking
sensitive internals.

Pagination must define ordering. Offset pagination is simple but can skip or
duplicate items when concurrent changes shift positions. Cursor pagination can
bind progress to a stable ordering key, but cursors need integrity and version
policy.

Conditional requests use validators such as ETags. A client can send a
precondition to prevent lost updates rather than performing an unsafe
read-modify-write sequence.

Version only when compatibility cannot be preserved. Whether the version lives
in a path, media type, or header is less important than coexistence,
observability, deprecation, and migration.

::: {.gotcha}
**Gotcha**

Returning HTTP 200 with an error field prevents intermediaries and generic
clients from applying ordinary HTTP failure semantics.
:::

## 4.4 - Returning and Rendering {#chapter-04-04}

The response retraces logical boundaries, not necessarily the same physical
network path. Each intermediary may buffer, compress, cache, transform allowed
metadata, or terminate a downstream connection.

The browser parses the status and headers before consuming content. Caching
rules determine whether the representation can be stored. Content encoding
such as compression is reversed before the media type is interpreted.

For HTML, the browser incrementally constructs a document model, discovers
subresources, and applies CSS. Scripts can block or modify parsing depending on
their attributes and execution. Layout computes geometry; painting produces
drawing operations; compositing combines layers. Exact pipelines are
browser-specific.

Subresources trigger their own URL journeys, though connection reuse,
multiplexing, DNS state, caches, preloading, and priorities can reduce repeated
work. A visually complete page is therefore not the same milestone as receiving
the first response byte.

Useful user-facing milestones include:

- navigation start;
- response headers or first byte;
- meaningful content rendered;
- main-thread responsiveness;
- completion of critical subresources;
- application-specific readiness.

Client CPU, memory pressure, long script tasks, fonts, and layout changes can
dominate after a fast backend response. Server traces alone cannot explain that
time.

::: {.gotcha}
**Gotcha**

“Page load time” is ambiguous. Define the observed milestone and the clock used
before comparing measurements.
:::

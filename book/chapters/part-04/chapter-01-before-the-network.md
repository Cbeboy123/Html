## 4.1 - Before the Network {#chapter-04-01}

The journey starts before a packet exists. The browser interprets input, applies
policy, and checks state that may make the network unnecessary.

The input may be parsed as a URL or transformed into a search request. A URL
contains a scheme, authority, path, query, and optional fragment under its
syntax. The fragment is normally interpreted by the client and is not sent in
the HTTP request.

The browser applies security policies such as blocked schemes, mixed-content
rules, and upgrade mechanisms. It may consult:

- an HTTP cache for a reusable representation;
- a service worker capable of handling the request;
- a pre-existing connection or connection pool;
- cached DNS information;
- proxy configuration and enterprise policy;
- credentials, cookies, and client certificates applicable to the destination.

Browser extensions can modify or block navigation. Exact ordering and cache
layers are browser-specific, so diagnosis must use that browser’s developer
tools and policy state.

If a fresh cached response satisfies the request, DNS and transport work may not
occur. A stale response may be revalidated conditionally. A service worker can
respond from its own storage, go to the network, or combine both.

::: {.gotcha}
**Gotcha**

“Clear the browser cache” is not a complete experiment. DNS caches, service
workers, proxies, operating-system state, and existing connections are separate
layers.
:::

::: {.interview-tip}
**Interview Tip**

Begin with URL parsing and local policy, not DNS. State which local checks could
short-circuit the remaining journey.
:::

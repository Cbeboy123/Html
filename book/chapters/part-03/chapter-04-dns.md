## 3.4 - DNS {#chapter-03-04}

Typing a host name does not usually cause the browser to contact the
authoritative server directly. Resolution crosses caches and delegated
authority.

~~~mermaid
sequenceDiagram
    participant App as Application
    participant Stub as Stub resolver
    participant Rec as Recursive resolver
    participant Root as Root server
    participant TLD as TLD server
    participant Auth as Authoritative server
    App->>Stub: Resolve name
    Stub->>Rec: Query
    Rec->>Root: Ask for name
    Root-->>Rec: Referral to TLD
    Rec->>TLD: Ask for name
    TLD-->>Rec: Referral to authority
    Rec->>Auth: Ask for record
    Auth-->>Rec: Answer
    Rec-->>Stub: Cached answer
    Stub-->>App: Addresses or error
~~~

*Diagram key: solid arrows are DNS queries; dashed arrows are answers or
referrals. A recursive resolver may answer from cache and skip later flights.*

The **stub resolver** is the local client-facing resolver. A **recursive
resolver** performs work on the client’s behalf. **Authoritative servers**
publish data for zones. Delegation connects the hierarchy; it is not a search
through one central database.

Records have TTLs that guide caching. TTL expiration permits refresh but does
not make change globally instantaneous: caches may have started at different
times, and application/OS caches add layers. Negative answers can also be
cached under DNS rules.

Common record purposes include addresses, aliases, mail routing, name-server
delegation, and arbitrary text. An alias chain still ends in data usable by the
client. DNS can return several addresses; selection and retry are client
behavior, not a DNS availability guarantee.

Failures include SERVFAIL from resolver/authority trouble, NXDOMAIN for a
nonexistent name, timeouts, broken delegation, stale caches, DNSSEC validation
failure, and split-horizon views. Diagnose by naming the resolver queried,
observed response code, authority path, and cache state.

::: {.interview-tip}
**Interview Tip**

Distinguish recursion from iteration, then mention positive and negative
caching. “DNS maps names to IPs” misses delegation, record types, and failure.
:::

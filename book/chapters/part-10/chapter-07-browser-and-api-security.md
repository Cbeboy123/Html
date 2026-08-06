## 10.7 - Browser and API Security {#chapter-10-07}

Browsers enforce the same-origin policy, but applications deliberately cross origins through links, forms, CORS, frames, and scripts. CORS tells a browser which origins may read a response; it is not network access control and does not stop non-browser clients.

Prevent XSS with context-aware output encoding, safe templating, reduced dangerous DOM APIs, and a restrictive Content Security Policy as defense in depth. Prevent CSRF for cookie-authenticated state changes with SameSite policy, anti-CSRF tokens, and origin checks. These threats differ: XSS executes in the trusted origin; CSRF induces a victim’s browser to send an authorized request.

APIs must bound size, nesting, rate, and decompressed work; validate syntax and domain invariants; parameterize queries; and avoid unsafe object deserialization. SSRF defenses require allowlisted destinations or controlled egress, URL parsing, DNS/rebinding awareness, and protection of cloud metadata/control endpoints.

Security headers address distinct concerns: transport enforcement, framing, content interpretation, referrer leakage, and browser capabilities. Apply them from a tested baseline and monitor violations without treating headers as the whole security program.

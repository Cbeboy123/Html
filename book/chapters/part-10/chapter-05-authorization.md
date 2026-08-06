## 10.5 - Authorization {#chapter-10-05}

Authorization decides whether a principal may perform an action on a resource in context. Enforce it server-side at every boundary and default deny. Object-level authorization is as important as endpoint access: permission to call `GET /orders/{id}` does not grant every order.

RBAC assigns permissions through roles; ABAC evaluates attributes and context; relationship-based models express graph-like ownership and sharing. Real systems often combine them. Central policy improves consistency, but enforcement points must receive trustworthy identity, resource attributes, and policy version.

Least privilege applies to users, services, operators, database roles, CI systems, and emergency access. Separate duties for irreversible or high-value actions. “Admin” should not become an unbounded escape hatch.

Authorization changes need auditability and revocation semantics. Cached decisions can remain valid after access is removed; define maximum staleness and fail-open/fail-closed behavior. Record who, what, resource, decision, policy, and correlation context without logging secrets.

::: {.gotcha}
**Gotcha**

Hiding a button is user experience, not authorization. The protected service must evaluate the decision.
:::

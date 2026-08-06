## 11.3 - Safe Production Change {#chapter-11-03}

Reduce change risk through small scope, staged exposure, fast detection, and a tested recovery path. A deployment installs code; a release exposes behavior. Feature flags can separate them, while canaries and progressive delivery compare a small population before broad rollout.

Define health before starting: user outcomes, error rate, latency, saturation, and domain invariants. Automated rollback helps only for reversible code/configuration. Database writes, external effects, and data migrations may require roll-forward or compensation.

Use expand-and-contract for schemas and protocols. Shadow traffic can compare behavior but must prevent duplicate effects and protect sensitive data. Blue/green reduces replacement time but doubles some capacity and complicates stateful compatibility.

Configuration is production code: validate types and ranges, review changes, stage them, record provenance, and bound dynamic updates. A kill switch needs ownership, authentication, observability, and regular testing.

::: {.gotcha}
**Gotcha**

“Rollback” is not a plan until you state what happens to data written by the new version and clients that adopted the new contract.
:::

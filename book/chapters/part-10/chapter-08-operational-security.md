## 10.8 - Operational Security {#chapter-10-08}

Secure software can still be operated insecurely. Build a verifiable chain from source review through isolated CI, pinned dependencies, artifact signing/provenance, controlled deployment, and runtime policy. Protect CI credentials because build systems can modify every shipped component.

Manage vulnerabilities by exploitability, exposure, and business impact—not raw counts. Maintain an inventory and software bill of materials, patch supported components, remove unused packages, and have a process for emergency updates.

Secrets belong in a managed secret system, delivered just in time and scoped to a workload. Do not put them in source, images, logs, command lines, or long-lived environment dumps. Rotation must be rehearsed, including downstream caches and revoked credentials.

Detection needs high-quality audit events, centralized tamper-resistant storage, correlation, and alerts tied to response actions. An incident plan covers containment, credential rotation, evidence preservation, customer/legal obligations, recovery, and lessons without blame.

Backups must be isolated from the credentials and control plane that can destroy production. Test restoration and protect the restore path as a privileged operation.

::: {.interview-tip}
**Interview Tip**

Connect prevention, detection, response, and recovery. “Encrypt everything” does not address compromise of an authorized runtime.
:::

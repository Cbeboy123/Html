## 11.2 - Continuous Integration and Delivery {#chapter-11-02}

Continuous integration means small changes merged frequently into a shared, releasable line with automated feedback. Continuous delivery keeps every validated revision deployable; continuous deployment automatically releases it. These are operating disciplines, not a particular server.

A strong pipeline is fast, deterministic, observable, and produces one immutable artifact promoted across environments. Stages commonly include source policy, compilation, unit/static/security checks, integration/contract tests, artifact attestation, deployment, and post-deploy verification. Environment-specific configuration is supplied at deploy time; rebuilding per environment destroys provenance.

Parallelize independent checks and run the fastest high-signal gates early. Cache carefully: a poisoned or incorrectly keyed cache can produce false success. Protect credentials, isolate untrusted pull-request code, pin toolchains, and preserve audit trails.

Database and contract changes must tolerate mixed versions. A green pipeline cannot compensate for an unsafe rollout. Measure lead time, deployment frequency, change failure rate, recovery time, queue time, and flaky-test burden to improve flow without gaming counts.

## 10.1 - Threats, Assets, and Trust Boundaries {#chapter-10-01}

Security starts with assets and adversaries, not controls. Identify data, money, identity, availability, code execution, reputation, and the administrative capabilities worth protecting. Then map actors, entry points, data flows, stores, and boundaries where trust changes.

Threat modeling asks what can go wrong and what evidence would reveal it. STRIDE is a useful prompt: spoofing, tampering, repudiation, information disclosure, denial of service, and elevation of privilege. It is not a substitute for domain abuse cases such as coupon farming, account recovery fraud, or insider misuse.

~~~mermaid
flowchart LR
    user([Untrusted client]) --> edge[Public edge]
    subgraph trusted[Service trust boundary]
      edge --> app[Application]
      app --> db[(Sensitive data)]
    end
    admin([Privileged operator]) --> app
~~~

*Diagram key: rounded boxes = external actors; rectangles = active components; cylinder = protected data; named subgraph = trust boundary.*

Risk combines likelihood and impact under uncertainty. Prioritize architectural controls—least privilege, isolation, safe workflows, strong identity, and reduced data—before detection-only measures. Revisit the model when data flow, deployment, vendors, or privileges change.

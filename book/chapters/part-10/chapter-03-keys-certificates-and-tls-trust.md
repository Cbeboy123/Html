## 10.3 - Keys, Certificates, and TLS Trust {#chapter-10-03}

A certificate binds a public key to identities and constraints under an issuer’s signature. A relying party builds and validates a chain to a trusted root, checks signatures, time validity, identity match, key usage, and applicable policy. Possessing a certificate file alone does not prove possession of its private key.

Private keys require lifecycle control: generation, inventory, scoped access, storage in a suitable key service or hardware boundary, rotation, revocation response, backup where appropriate, and destruction. Rotation must support overlap so old and new credentials coexist during rollout.

TLS termination defines where plaintext and authenticated peer identity become available. If a proxy terminates client TLS, downstream services must trust identity only through a protected, authenticated hop—not arbitrary forwarded headers. Mutual TLS authenticates both transport endpoints; it does not perform user authorization.

Certificate renewal should be automated and monitored for remaining lifetime and deployment success. Test the whole chain clients actually receive. Pinning and private CAs can reduce or change trust but raise recovery and distribution risk.

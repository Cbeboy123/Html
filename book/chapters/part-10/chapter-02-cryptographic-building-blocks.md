## 10.2 - Cryptographic Building Blocks {#chapter-10-02}

Cryptography provides narrowly defined properties. A cryptographic hash maps input to a fixed-size digest and should resist practical preimage and collision attacks. A MAC authenticates data using a shared secret. A digital signature authenticates with a private key and verifies with a public key. Encryption provides confidentiality; authenticated encryption also detects tampering.

Never design a new cryptographic protocol. Use maintained libraries and standard constructions. Nonces/IVs have algorithm-specific uniqueness or unpredictability requirements; reuse can catastrophically reveal plaintext or keys. Random tokens need a cryptographically secure generator and sufficient entropy.

Passwords are not encryption keys. Store them with a purpose-built, salted, adaptive password hashing function and tune cost for current hardware. A salt prevents shared precomputation; an optional pepper is a separately protected secret, not a replacement.

Encoding, hashing, encryption, and signing are not interchangeable. Base64 only represents bytes. Hashing does not hide low-entropy values. Encryption without authentication can permit undetected modification.

::: {.interview-tip}
**Interview Tip**

State the property, attacker, and key ownership. Algorithm names without a threat model are cargo culting.
:::

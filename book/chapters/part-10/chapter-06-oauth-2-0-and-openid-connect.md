## 10.6 - OAuth 2.0 and OpenID Connect {#chapter-10-06}

OAuth 2.0 delegates authorization: a resource owner permits a client to access a resource server under scopes and policy. OpenID Connect adds an identity layer and an ID token intended for the client. An access token is for the resource server; an ID token is not a general API credential.

For user-facing applications, authorization code flow with PKCE binds the code to the initiating client and avoids exposing credentials in the browser URL. Redirect URIs must be strictly registered. State protects request correlation/CSRF; nonce binds an OIDC authentication response to the client session.

JWT is a token format, not an authentication protocol. A verifier must restrict algorithms, validate signature and issuer, require the correct audience, enforce time claims with bounded skew, and interpret scopes/claims under a local policy. Key rotation and revocation need explicit design. Opaque tokens plus introspection can provide more immediate central control.

Refresh tokens are powerful long-lived credentials. Rotate or sender-constrain them where supported, protect them from untrusted script, and detect reuse. Use short-lived access tokens, narrow audience/scope, and never put secrets or unnecessary personal data into readable token claims.

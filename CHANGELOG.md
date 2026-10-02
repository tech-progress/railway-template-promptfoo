# Changelog

## [1.0.3] - 2026-10-02

- Pin Promptfoo 0.123.1 to its verified multi-architecture digest while preserving root volume bootstrap, privilege dropping, the upstream server command, and Basic Auth gateway.
- Identify the unchanged Caddy artifact with the explicit 2.10.2 patch tag in Compose and Railway configuration.
- Refresh version assertions and document ESM, filesystem blob storage, libsql SQLite, and Node 20 removal upgrade gates. Existing 0.117.2-state migration and cloud publication remain unverified.

## [1.0.2] - 2026-08-01

- Preserve mixed GitHub and image sources when restoring and auditing the generated template draft.

## [1.0.1] - 2026-08-01

- Declare Promptfoo's port explicitly for Railway platform health checks.

## [1.0.0] - 2026-08-01

- Publish Promptfoo 0.117.2 behind a generated Basic Auth gateway.
- Persist the SQLite database and configuration on a 5 GB Railway volume.
- Disable telemetry, update checks, remote generation, and hosted sharing by default.
- Bootstrap Railway volume ownership as root, then drop to the upstream Promptfoo user before server startup.

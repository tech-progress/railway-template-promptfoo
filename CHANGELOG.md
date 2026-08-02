# Changelog

## [1.0.1] - 2026-08-01

- Declare Promptfoo's port explicitly for Railway platform health checks.

## [1.0.0] - 2026-08-01

- Publish Promptfoo 0.117.2 behind a generated Basic Auth gateway.
- Persist the SQLite database and configuration on a 5 GB Railway volume.
- Disable telemetry, update checks, remote generation, and hosted sharing by default.
- Bootstrap Railway volume ownership as root, then drop to the upstream Promptfoo user before server startup.

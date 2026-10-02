# Upgrade

Back up the Promptfoo volume, update Promptfoo's semantic tag and multi-architecture digest together in `Dockerfile`, then update Caddy's pin in `compose.yaml` and `.railway/railway.ts` when needed. Rerun structure, local evaluation, restart-persistence, and clean Railway deployment checks. Promptfoo may migrate SQLite data on startup, so test upgrades against a copy before changing a live deployment.

## 1.0.3 / Promptfoo 0.123.1

Stop evaluations and the server before taking a consistent backup of the entire `/home/promptfoo/.promptfoo` volume, not just the SQLite file. Preserve configuration, database sidecars, and filesystem blobs together. Default blob storage lives under the configured directory, so the existing volume mount covers it. Keep the old image and configuration; rollback requires restoring the matching pre-upgrade volume, not running the old image against migrated data.

Review upstream [ESM in 0.120.0](https://github.com/promptfoo/promptfoo/releases/tag/0.120.0), [blob storage in 0.120.7](https://github.com/promptfoo/promptfoo/releases/tag/0.120.7), [libsql SQLite in 0.121.13](https://github.com/promptfoo/promptfoo/releases/tag/0.121.13), and [Node 20 removal in 0.122.0](https://github.com/promptfoo/promptfoo/releases/tag/0.122.0). The new upstream container supplies its Node runtime; custom providers/assertions must be tested under its ESM behavior, including imports and CommonJS fallbacks.

Upgrade an isolated copy of initialized 0.117.2 data, verify old evaluations and configuration, exercise blob/media read/write and custom extensions, then run an authenticated evaluation and restart-persistence check. The root ownership bootstrap, non-root server, and gateway remain unchanged; clean-state and same-version restart checks do not prove an existing-volume migration or absence of breaking changes.

# Upgrade

Back up the Promptfoo volume, update Promptfoo's semantic tag and multi-architecture digest together in `Dockerfile`, then update Caddy's pin in `compose.yaml` and `.railway/railway.ts` when needed. Rerun structure, local evaluation, restart-persistence, and clean Railway deployment checks. Promptfoo may migrate SQLite data on startup, so test upgrades against a copy before changing a live deployment.

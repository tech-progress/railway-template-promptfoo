# Upgrade

Back up the Promptfoo volume, update the semantic tag and multi-architecture digest together in `compose.yaml` and `.railway/railway.ts`, then rerun structure, local evaluation, restart-persistence, and clean Railway deployment checks. Promptfoo may migrate SQLite data on startup, so test upgrades against a copy before changing a live deployment.


# Publishing

The current template release is `v1.0.3`. The published template ID is `82fc4a12-98aa-4e5f-8bbb-d6025b65af63`, its code is `promptfoo-evaluation`, and its public URL is `https://railway.com/deploy/promptfoo-evaluation`. This local maintenance candidate has not been copied to the public `tech-progress/railway-template-promptfoo` mirror or published; the next release targets `release-v1` and immutable tag `v1.0.3`.

The candidate pins Promptfoo `0.123.1` and Caddy `2.10.2` (the gateway digest is unchanged). Follow [UPGRADE.md](UPGRADE.md) for full-volume backup, initialized-state migration, ESM custom extension, and blob persistence gates. A clean-state evaluation does not prove an upgrade from 0.117.2. Cloud checks below require separate authorization and are not part of this maintenance pass.

Run `bun install --frozen-lockfile`, `./scripts/verify.sh`, the local smoke and restart workflow, a clean Railway deployment, and `./scripts/audit-template.sh TEMPLATE_ID`. Publish only when anonymous access returns 401 and an authenticated evaluation survives a Promptfoo restart.

```bash
railway templates publish TEMPLATE_ID \
  --category AI/ML \
  --description "Private Promptfoo evaluation and red teaming with persistent project data." \
  --readme-file MARKETPLACE.md \
  --json
```

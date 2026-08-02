# Publishing

The current template release is `v1.0.2`. The published template ID is `82fc4a12-98aa-4e5f-8bbb-d6025b65af63`, its code is `promptfoo-evaluation`, and its public URL is `https://railway.com/deploy/promptfoo-evaluation`. The public `tech-progress/railway-template-promptfoo` mirror publishes `release-v1` and immutable tag `v1.0.2`.

Run `bun install --frozen-lockfile`, `./scripts/verify.sh`, the local smoke and restart workflow, a clean Railway deployment, and `./scripts/audit-template.sh TEMPLATE_ID`. Publish only when anonymous access returns 401 and an authenticated evaluation survives a Promptfoo restart.

```bash
railway templates publish TEMPLATE_ID \
  --category AI/ML \
  --description "Promptfoo evaluation UI with authenticated access and durable results." \
  --readme-file MARKETPLACE.md \
  --json
```

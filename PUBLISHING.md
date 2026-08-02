# Publishing

The current template release is `v1.0.2`. Publish the public `tech-progress/railway-template-promptfoo` mirror at `release-v1` and tag `v1.0.2` before applying the graph. Both base images use immutable multi-architecture digests, only the Basic Auth gateway is public, and Promptfoo has a 5 GB persistent volume.

Run `bun install --frozen-lockfile`, `./scripts/verify.sh`, the local smoke and restart workflow, a clean Railway deployment, and `./scripts/audit-template.sh TEMPLATE_ID`. Publish only when anonymous access returns 401 and an authenticated evaluation survives a Promptfoo restart.

```bash
railway templates publish TEMPLATE_ID \
  --category AI/ML \
  --description "Promptfoo evaluation UI with authenticated access and durable results." \
  --readme-file MARKETPLACE.md \
  --json
```

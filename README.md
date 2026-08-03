# Promptfoo evaluation on Railway

This template deploys Promptfoo's community self-hosted UI and API behind Caddy Basic Auth. Promptfoo stays private, stores its SQLite database and configuration on a 5 GB volume, and disables telemetry, update checks, remote generation, and hosted sharing by default.

Upstream project: [Promptfoo](https://promptfoo.dev).

The current template release is `v1.0.2` and pins Promptfoo `0.117.2` plus Caddy `2.10` by immutable multi-architecture digests. Railway builds the small volume-permission wrapper from `tech-progress/railway-template-promptfoo` on `release-v1`; it drops back to Promptfoo's UID before starting the upstream server.

## Use on Railway

Deploy the template, open `Promptfoo Gateway`, and sign in with its generated `PROMPTFOO_USERNAME` and `PROMPTFOO_PASSWORD`. Add model-provider keys to the private `Promptfoo` service only; for example, set `OPENAI_API_KEY` there before running OpenAI-backed evaluations.

Promptfoo's community server has no built-in authentication, so only the gateway receives a public domain. Do not expose the private Promptfoo service directly.

## Environment variables

No user-supplied variable is required for deployment. Railway configures this complete service contract:

| Service | Variable | Default | Purpose |
| --- | --- | --- | --- |
| Promptfoo | `PORT` | `3000` | Declares the application listener to Railway. |
| Promptfoo | `API_PORT` | `3000` | Selects Promptfoo's HTTP server port. |
| Promptfoo | `HOST` | `0.0.0.0` | Documents the container network binding. |
| Promptfoo | `PROMPTFOO_CONFIG_DIR` | `/home/promptfoo/.promptfoo` | Places SQLite data and configuration on the volume. |
| Promptfoo | `PROMPTFOO_SELF_HOSTED` | `1` | Enables self-hosted behavior. |
| Promptfoo | `PROMPTFOO_DISABLE_TELEMETRY` | `1` | Disables telemetry. |
| Promptfoo | `PROMPTFOO_DISABLE_UPDATE` | `1` | Disables update checks. |
| Promptfoo | `PROMPTFOO_DISABLE_REMOTE_GENERATION` | `true` | Disables Promptfoo-hosted generation and grading. |
| Promptfoo | `PROMPTFOO_DISABLE_SHARING` | `1` | Disables hosted result sharing. |
| Promptfoo Gateway | `PORT` | `8080` | Declares the gateway listener to Railway. |
| Promptfoo Gateway | `PROMPTFOO_USERNAME` | `promptfoo` | Sets the Basic Auth username. |
| Promptfoo Gateway | `PROMPTFOO_PASSWORD` | generated 32-character secret | Sets the Basic Auth password. |
| Promptfoo Gateway | `PROMPTFOO_UPSTREAM` | private Promptfoo URL on port 3000 | Routes authenticated requests to the private service. |

Model-provider credentials such as `OPENAI_API_KEY` are optional and belong only on the private `Promptfoo` service.

## Limits

This is Promptfoo's community server for individual and experimental use. It uses SQLite, keeps running jobs in memory, supports one replica, has no built-in SSO, and does not provide supported scheduling. Back up `/home/promptfoo/.promptfoo` before upgrades.

## Local verification

```bash
bun install --frozen-lockfile
./scripts/verify.sh
PROMPTFOO_PASSWORD=local-test-password docker compose up -d
PROMPTFOO_PASSWORD=local-test-password ./scripts/smoke.sh
```

The smoke script prints the evaluation ID. Restart Promptfoo, then set `PROMPTFOO_SMOKE_EVAL_ID` and `PROMPTFOO_VERIFY_ONLY=true` to verify persistence.

# Deploy and Host Promptfoo on Railway

Deploy Promptfoo's LLM evaluation and red-team UI behind an authenticated gateway with persistent local results.

## About Hosting Promptfoo

Promptfoo is an MIT-licensed toolkit for testing prompts, models, agents, and security behavior. This template runs its community self-hosted UI and API as a private service while Caddy provides generated Basic Auth at the public edge.

## Why Deploy Promptfoo on Railway

Railway supplies private networking, a persistent 5 GB volume, generated gateway credentials, and health-checked services in one deployment. Telemetry, update checks, remote generation, and hosted result sharing are disabled by default, so evaluation data stays with the deployment unless a configured model provider receives it.

## Common Use Cases

- Compare prompts and model providers with repeatable test cases.
- Review evaluation results in a shared, authenticated UI.
- Run red-team experiments against development AI systems.

## Dependencies for Promptfoo Hosting

### Deployment Dependencies

The template includes Promptfoo `0.117.2`, Caddy `2.10`, and a 5 GB persistent volume. Add provider API keys to the private `Promptfoo` service when required.

After deployment, open `Promptfoo Gateway` and use its generated username and password. The community server uses SQLite, supports one replica, has in-memory jobs, and does not include built-in SSO or supported scheduling, so this template is intended for individual and experimental deployments.

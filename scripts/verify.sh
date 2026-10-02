#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(.dockerignore .env.example .gitignore .railway/railway.ts CHANGELOG.md Dockerfile FINDINGS.md LICENSE_REVIEW.md MARKETPLACE.md PUBLISHING.md README.md SUPPORT.md UPGRADE.md VERSION bun.lock compose.yaml package.json railway-entrypoint.sh template-defaults.json template-descriptions.json template-networking.json template-volumes.json scripts/audit-template.sh scripts/check-standalone.sh scripts/restore-template-draft.sh scripts/smoke.sh scripts/verify.sh)
for file in "${required[@]}"; do test -f "${template_root}/${file}" || { echo "Missing ${file}" >&2; exit 1; }; done

version="$(<"${template_root}/VERSION")"; [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
grep -Eq "^## \[${version//./\\.}\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$" "${template_root}/CHANGELOG.md"
for file in README.md PUBLISHING.md; do grep -Fq "current template release is \`v${version}\`" "${template_root}/${file}"; done
publish_description="$(grep -E '^  --description "' "${template_root}/PUBLISHING.md" | cut -d '"' -f 2)"
[[ -n "${publish_description}" && ${#publish_description} -le 75 ]]
for heading in '# Deploy and Host' '## About Hosting' '## Why Deploy' '## Common Use Cases' '## Dependencies for' '### Deployment Dependencies'; do
  grep -Fq "${heading}" "${template_root}/MARKETPLACE.md"
done

PROMPTFOO_PASSWORD=verify-password docker compose -f "${template_root}/compose.yaml" config --quiet
for file in template-defaults.json template-descriptions.json template-networking.json template-volumes.json; do jq empty "${template_root}/${file}"; done
jq -e --slurpfile descriptions "${template_root}/template-descriptions.json" '
  (keys | sort) == ($descriptions[0] | keys | sort) and
  ([keys[] as $service | (.[$service] | keys | sort) == ($descriptions[0][$service] | keys | sort)] | all)
' "${template_root}/template-defaults.json" >/dev/null
for file in scripts/audit-template.sh scripts/check-standalone.sh scripts/restore-template-draft.sh scripts/smoke.sh scripts/verify.sh; do bash -n "${template_root}/${file}"; done

graph="$(cd "${template_root}" && ./node_modules/.bin/railway-iac-ts .railway/railway.ts)"
jq -e '
  .graph.resources |
  ([.[] | select(.type=="service") | .name] | sort) == ["Promptfoo","Promptfoo Gateway"] and
  ([.[] | select(.type=="volume" and .name=="Promptfoo Data" and .config.sizeMB==5000)] | length) == 1 and
  ([.[] | select(.name=="Promptfoo")][0].source.repo == "tech-progress/railway-template-promptfoo") and
  ([.[] | select(.name=="Promptfoo")][0].source.branch == "release-v1") and
  ([.[] | select(.name=="Promptfoo")][0].build.dockerfilePath == "Dockerfile") and
  ([.[] | select(.name=="Promptfoo")][0].deploy.startCommand == null) and
  ([.[] | select(.name=="Promptfoo")][0].deploy.healthcheckPath == "/health") and
  ([.[] | select(.name=="Promptfoo Gateway")][0].deploy.startCommand | contains("caddy hash-password")) and
  ([.[] | select(.name=="Promptfoo Gateway")][0].deploy.healthcheckPath == "/healthz")
' <<<"${graph}" >/dev/null

grep -Fq 'FROM ghcr.io/promptfoo/promptfoo:0.123.1@sha256:' "${template_root}/Dockerfile"
grep -Fq 'CMD ["node", "dist/src/server/index.js"]' "${template_root}/Dockerfile"
for file in compose.yaml .railway/railway.ts; do
  grep -Fq 'caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d' "${template_root}/${file}"
done
for pin in 2dfddde000886e9a0bcce799478095a2e7d1e4438a6c6669ac04001e8ae29b85 4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d; do
  grep -Rqs "${pin}" "${template_root}/compose.yaml" "${template_root}/Dockerfile" "${template_root}/.railway/railway.ts"
done
grep -Fq "su -s /bin/sh promptfoo" "${template_root}/railway-entrypoint.sh"
jq -e '."Promptfoo Gateway".PROMPTFOO_PASSWORD=="${{secret(32)}}" and .Promptfoo.PROMPTFOO_DISABLE_TELEMETRY=="1" and .Promptfoo.PROMPTFOO_DISABLE_REMOTE_GENERATION=="true"' "${template_root}/template-defaults.json" >/dev/null
if find "${template_root}" -type f \( -name .env -o -name '*.local' \) -print -quit | grep -q .; then echo "Local secret file found." >&2; exit 1; fi
echo "Promptfoo template structure, pins, authentication, variables, volume, and networking are valid."

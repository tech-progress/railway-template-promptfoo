import { defineRailway, github, group, project, service, volume } from "railway/iac";

const PROMPTFOO_SOURCE = github("tech-progress/railway-template-promptfoo", {
  branch: "release-v1",
  rootDirectory: "/",
});
const CADDY_IMAGE =
  "caddy:2.10-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d";

export default defineRailway(() => {
  const promptfooData = volume("Promptfoo Data", { sizeMB: 5_000 });

  const promptfoo = service("Promptfoo", {
    source: PROMPTFOO_SOURCE,
    build: {
      builder: "DOCKERFILE",
      dockerfilePath: "Dockerfile",
      watchPatterns: ["/Dockerfile", "/railway-entrypoint.sh"],
    },
    healthcheck: "/health",
    healthcheckTimeout: 300,
    volumeMounts: { "/home/promptfoo/.promptfoo": promptfooData },
    env: {
      PORT: "3000",
      API_PORT: "3000",
      HOST: "0.0.0.0",
      PROMPTFOO_CONFIG_DIR: "/home/promptfoo/.promptfoo",
      PROMPTFOO_SELF_HOSTED: "1",
      PROMPTFOO_DISABLE_TELEMETRY: "1",
      PROMPTFOO_DISABLE_UPDATE: "1",
      PROMPTFOO_DISABLE_REMOTE_GENERATION: "true",
      PROMPTFOO_DISABLE_SHARING: "1",
    },
  });

  const gateway = service("Promptfoo Gateway", {
    source: { image: CADDY_IMAGE },
    start:
      "/bin/sh -ec 'password_hash=\"$(caddy hash-password --plaintext \"$PROMPTFOO_PASSWORD\")\"; printf '\"'\"':8080 {\\n handle /healthz {\\n  respond \"ok\" 200\\n }\\n handle {\\n  basic_auth {\\n   %s %s\\n  }\\n  reverse_proxy %s\\n }\\n}\\n'\"'\"' \"$PROMPTFOO_USERNAME\" \"$password_hash\" \"$PROMPTFOO_UPSTREAM\" >/tmp/Caddyfile; exec caddy run --config /tmp/Caddyfile --adapter caddyfile'",
    healthcheck: "/healthz",
    healthcheckTimeout: 300,
    env: {
      PORT: "8080",
      PROMPTFOO_USERNAME: "promptfoo",
      PROMPTFOO_PASSWORD: "${{secret(32)}}",
      PROMPTFOO_UPSTREAM: "http://${{Promptfoo.RAILWAY_PRIVATE_DOMAIN}}:3000",
    },
  });

  return project("Promptfoo evaluation", {
    resources: [group("Application", [gateway, promptfoo, promptfooData])],
  });
});

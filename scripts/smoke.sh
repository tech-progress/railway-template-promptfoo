#!/usr/bin/env bash
set -euo pipefail

promptfoo_url="${1:-http://localhost:8380}"
username="${PROMPTFOO_USERNAME:-promptfoo}"
password="${PROMPTFOO_PASSWORD:?Set PROMPTFOO_PASSWORD}"

ready=false
for _ in {1..90}; do
  if curl --fail --silent "${promptfoo_url}/healthz" >/dev/null 2>&1 &&
     curl --user "${username}:${password}" --fail --silent "${promptfoo_url}/health" >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 2
done
[[ "${ready}" == "true" ]] || { echo "Promptfoo gateway did not become ready." >&2; exit 1; }

status="$(curl --silent --output /dev/null --write-out '%{http_code}' "${promptfoo_url}/")"
[[ "${status}" == "401" ]] || { echo "Gateway allowed an unauthenticated request (${status})." >&2; exit 1; }

api() { curl --user "${username}:${password}" --fail --silent --show-error "$@"; }
api "${promptfoo_url}/health" | jq -e '.status == "OK"' >/dev/null

if [[ "${PROMPTFOO_VERIFY_ONLY:-false}" == "true" ]]; then
  eval_id="${PROMPTFOO_SMOKE_EVAL_ID:?Set PROMPTFOO_SMOKE_EVAL_ID}"
  api "${promptfoo_url}/api/results/${eval_id}" | jq -e '.data.results.results | length == 1' >/dev/null
  echo "Promptfoo retained the evaluation after restart."
  exit 0
fi

payload='{"config":{"description":"Railway persistence smoke","prompts":["Hello {{name}}"],"providers":["echo"],"tests":[{"vars":{"name":"Railway"}}]},"prompts":[{"raw":"Hello {{name}}","label":"Hello {{name}}","provider":"echo","metrics":{"score":1,"testPassCount":1,"testFailCount":0,"assertPassCount":1,"assertFailCount":0,"totalLatencyMs":1,"tokenUsage":{"total":0,"prompt":0,"completion":0,"cached":0}}}],"vars":["name"],"results":[{"promptIdx":0,"testIdx":0,"testCase":{"vars":{"name":"Railway"}},"prompt":{"raw":"Hello {{name}}","label":"Hello {{name}}"},"provider":{"id":"echo"},"response":{"output":"Hello Railway"},"success":true,"score":1,"latencyMs":1,"gradingResult":{"pass":true,"score":1,"reason":"Echo output matched","componentResults":[]}}],"createdAt":"2026-08-01T00:00:00.000Z"}'
eval_id="$(api -H 'Content-Type: application/json' --data-binary "${payload}" "${promptfoo_url}/api/eval" | jq -er '.id')"
api "${promptfoo_url}/api/results/${eval_id}" | jq -e '.data.results.results[0].response.output == "Hello Railway"' >/dev/null
printf '%s\n' "${eval_id}"

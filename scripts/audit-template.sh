#!/usr/bin/env bash
set -euo pipefail

template_id="${1:?Usage: ./scripts/audit-template.sh TEMPLATE_ID [EXPECTED_STATUS]}"
expected_status="${2:-}"
template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template_json="$(railway api 'query Audit($id: String!) { template(id: $id) { name status serializedConfig } }' --var "id=${template_id}" --compact)"
graph_json="$(cd "${template_root}" && ./node_modules/.bin/railway-iac-ts .railway/railway.ts)"

[[ "$(jq -r '.data.template.name' <<<"${template_json}")" == "Promptfoo evaluation" ]]
[[ -z "${expected_status}" || "$(jq -r '.data.template.status' <<<"${template_json}")" == "${expected_status}" ]]
[[ "$(jq -r '.data.template.serializedConfig.services | [.[] | .name] | sort | join("\n")' <<<"${template_json}")" == $'Promptfoo\nPromptfoo Gateway' ]]

failures=0
for service_name in "Promptfoo" "Promptfoo Gateway"; do
  desired="$(jq -c --arg service "${service_name}" '.graph.resources[] | select(.type == "service" and .name == $service)' <<<"${graph_json}")"
  actual="$(jq -c --arg service "${service_name}" '[.data.template.serializedConfig.services[] | select(.name == $service)][0]' <<<"${template_json}")"
  [[ "$(jq -r '.source.image' <<<"${actual}")" == "$(jq -r '.source.image' <<<"${desired}")" ]] || failures=$((failures + 1))
  for field in startCommand healthcheckPath healthcheckTimeout; do
    [[ "$(jq -r --arg f "${field}" '.deploy[$f] // ""' <<<"${actual}")" == "$(jq -r --arg f "${field}" '.deploy[$f] // ""' <<<"${desired}")" ]] || failures=$((failures + 1))
  done
  while IFS= read -r variable; do
    key="$(jq -r '.key' <<<"${variable}")"; expected="$(jq -r '.value' <<<"${variable}")"
    [[ "$(jq -r --arg key "${key}" '.variables[$key].defaultValue // "__MISSING__"' <<<"${actual}")" == "${expected:-__MISSING__}" ]] || failures=$((failures + 1))
    [[ "$(jq -r --arg key "${key}" '.variables[$key].isOptional // false' <<<"${actual}")" == "false" ]] || failures=$((failures + 1))
  done < <(jq -c --arg service "${service_name}" '.[$service] | to_entries[]' "${template_root}/template-defaults.json")
done

expected_volume="$(jq -c '.Promptfoo' "${template_root}/template-volumes.json")"
actual_volume="$(jq -c '[.data.template.serializedConfig.services[] | select(.name == "Promptfoo") | .volumeMounts[] | {mountPath,sizeMB}][0]' <<<"${template_json}")"
[[ "${actual_volume}" == "${expected_volume}" ]] || failures=$((failures + 1))
expected_port="$(jq -r '."Promptfoo Gateway".publicPort' "${template_root}/template-networking.json")"
actual_port="$(jq -r '[.data.template.serializedConfig.services[] | select(.name == "Promptfoo Gateway") | .networking.serviceDomains["<hasDomain>"].port][0] // 0' <<<"${template_json}")"
[[ "${actual_port}" == "${expected_port}" ]] || failures=$((failures + 1))
(( failures == 0 )) || { echo "Promptfoo template audit failed with ${failures} mismatch(es)." >&2; exit 1; }
echo "Template ${template_id} matches Promptfoo images, authentication, defaults, volume, and networking."


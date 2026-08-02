#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
standalone_dir="${1:?Usage: ./scripts/check-standalone.sh STANDALONE_DIR}"

[[ -d "${standalone_dir}/.git" ]] || { echo "Standalone Promptfoo repository not found." >&2; exit 1; }
[[ ! -e "${standalone_dir}/FINDINGS.md" ]] || { echo "FINDINGS.md must remain private to the monorepo." >&2; exit 1; }
diff -qr --exclude=.git --exclude=FINDINGS.md --exclude=node_modules "${template_root}" "${standalone_dir}"
echo "Promptfoo monorepo and standalone distribution files match."


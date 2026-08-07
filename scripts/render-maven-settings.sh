#!/usr/bin/env bash
# Render Maven settings for direct Lightwell access (no Nexus)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT}/scripts/lightwell-env.sh"

: "${LIGHTWELL_USERNAME:?set LIGHTWELL_USERNAME}"
: "${LIGHTWELL_TOKEN:?set LIGHTWELL_TOKEN}"

OUT="${1:-${ROOT}/app/settings-lightwell-direct.xml}"
TEMPLATE="${ROOT}/app/settings-lightwell-direct.xml.template"

python - "$TEMPLATE" "$OUT" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
repl = {
    "__LIGHTWELL_SERVER_ID__": os.environ["LIGHTWELL_SERVER_ID"],
    "__LIGHTWELL_URL__": os.environ["LIGHTWELL_URL"],
    "__LIGHTWELL_USERNAME__": os.environ["LIGHTWELL_USERNAME"],
    "__LIGHTWELL_PASSWORD__": os.environ["LIGHTWELL_TOKEN"],
}
for k, v in repl.items():
    text = text.replace(k, v)
open(dst, "w", encoding="utf-8").write(text)
print(f"Wrote {dst}")
PY

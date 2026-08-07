#!/usr/bin/env bash
# Reconfigure Nexus Lightwell proxy (tier switch validated -> remediated)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT}/scripts/lightwell-env.sh"

NS="${NS:-$(oc project -q)}"
NEXUS_URL="${NEXUS_URL:-http://nexus:8081}"
ADMIN_PASS="${NEXUS_ADMIN_PASSWORD:-admin123}"
: "${LIGHTWELL_USERNAME:?}"
: "${LIGHTWELL_TOKEN:?}"

echo "Configuring Nexus proxy ${LIGHTWELL_REPO_NAME} -> ${LIGHTWELL_URL}"
# Prefer in-cluster; from laptop use route
if ! curl -sf -o /dev/null "${NEXUS_URL}/"; then
  HOST=$(oc get route nexus -n "${NS}" -o jsonpath='{.spec.host}')
  NEXUS_URL="https://${HOST}"
fi

AUTH=(-u "admin:${ADMIN_PASS}")
# Delete existing repo if present then recreate (simple demo approach)
curl -sf "${AUTH[@]}" -X DELETE \
  "${NEXUS_URL}/service/rest/v1/repositories/${LIGHTWELL_REPO_NAME}" || true

curl -sf "${AUTH[@]}" -H "Content-Type: application/json" \
  -X POST "${NEXUS_URL}/service/rest/v1/repositories/maven/proxy" \
  -d @- <<EOF
{
  "name": "${LIGHTWELL_REPO_NAME}",
  "online": true,
  "storage": { "blobStoreName": "default", "strictContentTypeValidation": true },
  "proxy": { "remoteUrl": "${LIGHTWELL_URL}", "contentMaxAge": 1440, "metadataMaxAge": 1440 },
  "negativeCache": { "enabled": true, "timeToLive": 1440 },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "authentication": { "type": "username", "username": "${LIGHTWELL_USERNAME}", "password": "${LIGHTWELL_TOKEN}" }
  },
  "maven": { "versionPolicy": "RELEASE", "layoutPolicy": "STRICT" }
}
EOF
echo "OK"

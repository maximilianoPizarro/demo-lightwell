#!/usr/bin/env bash
# Journey step 1: bring up Nexus + JBoss (contingency image) + optional Tekton
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NS="${NS:-$(oc project -q)}"

echo "== demo-up in namespace ${NS} =="

if ! oc get secret lightwell-sa -n "${NS}" >/dev/null 2>&1; then
  echo "Missing secret lightwell-sa. Run scripts/setup-secrets.sh first." >&2
  exit 1
fi

echo "-- Helm: Nexus --"
helm upgrade --install nexus "${ROOT}/charts/nexus" -n "${NS}" --wait --timeout 10m || {
  echo "Helm wait timed out; continuing to check pods..."
  oc get pods -n "${NS}" -l app.kubernetes.io/name=nexus || true
}

echo "-- Helm: JBoss app (tag=contingency by default) --"
IMAGE_TAG="${IMAGE_TAG:-contingency}"
if oc get pipelinerun -n "${NS}" >/dev/null 2>&1; then
  echo "Tekton available — starting pipeline (best effort)..."
  oc apply -f "${ROOT}/pipelines/" -n "${NS}" || true
  if command -v tkn >/dev/null; then
    tkn pipeline start lightwell-build-deploy -n "${NS}" --showlog=false \
      --workspace name=source,emptyDir="" \
      --param IMAGE_TAG=latest || true
    IMAGE_TAG="latest"
  fi
fi

helm upgrade --install jboss-app "${ROOT}/charts/jboss-app" -n "${NS}" \
  --set image.tag="${IMAGE_TAG}" \
  --wait --timeout 8m || true

NEXUS_HOST=$(oc get route nexus -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)
APP_HOST=$(oc get route jboss-app -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)
MGMT_HOST=$(oc get route jboss-app-mgmt -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)

echo
echo "App:      https://${APP_HOST}"
echo "Console:  https://${MGMT_HOST}"
echo "Nexus:    https://${NEXUS_HOST}"
echo "Next:     open app/pom.xml → RHDA report → task open-jboss-console"

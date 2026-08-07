#!/usr/bin/env bash
# Journey step 1: install the umbrella chart
# - secrets + Nexus + Lightwell proxy
# - Tekton PipelineRun → OpenShift internal registry (Quay optional)
# - DevWorkspace in Dev Spaces namespace
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NS="${NS:-$(oc project -q)}"
RELEASE="${RELEASE:-demo}"

echo "== demo-up in namespace ${NS} (release=${RELEASE}) =="

if grep -qE 'lightwell:\s*$|username: "CHANGE_ME"|token: "CHANGE_ME"' "${ROOT}/charts/demo-lightwell/values.yaml" \
  && grep -q 'CHANGE_ME' "${ROOT}/charts/demo-lightwell/values.yaml"; then
  # Only fail if lightwell credentials still placeholder
  if grep -A2 '^lightwell:' "${ROOT}/charts/demo-lightwell/values.yaml" | grep -q 'CHANGE_ME'; then
    echo "ERROR: edit charts/demo-lightwell/values.yaml lightwell.username / lightwell.token" >&2
    exit 1
  fi
fi

INTERNAL_IMAGE="image-registry.openshift-image-registry.svc:5000/${NS}/demo-lightwell"

helm dependency update "${ROOT}/charts/demo-lightwell"
helm upgrade --install "${RELEASE}" "${ROOT}/charts/demo-lightwell" -n "${NS}" \
  --set "jboss-app.image.repository=${INTERNAL_IMAGE}" \
  --set jboss-app.image.tag=latest \
  --set 'jboss-app.image.pullSecrets={}' \
  --wait --timeout 12m \
  || echo "WARN: helm --wait timed out (Nexus/JBoss may still be starting; PipelineRun continues)."

echo
echo "Internal image target: ${INTERNAL_IMAGE}:latest"
echo "PipelineRuns:"
oc get pipelinerun -n "${NS}" 2>/dev/null || true
DS_NS="${NS%-dev}-devspaces"
if [[ "${NS}" == *-dev ]]; then
  echo "DevWorkspace namespace: ${DS_NS}"
  oc get devworkspace -n "${DS_NS}" 2>/dev/null || true
fi

NEXUS_HOST=$(oc get route nexus -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)
APP_HOST=$(oc get route jboss-app -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)
MGMT_HOST=$(oc get route jboss-app-mgmt -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)

echo
echo "App:      https://${APP_HOST}"
echo "Console:  https://${MGMT_HOST}"
echo "Nexus:    https://${NEXUS_HOST}"
echo "Next:     open Dev Spaces workspace → app/pom.xml → RHDA (CVEs)"

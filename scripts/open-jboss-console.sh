#!/usr/bin/env bash
# Journey step 3: print / open JBoss management console URL
set -euo pipefail
NS="${NS:-$(oc project -q)}"
MGMT_HOST=$(oc get route jboss-app-mgmt -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)
APP_HOST=$(oc get route jboss-app -n "${NS}" -o jsonpath='{.spec.host}' 2>/dev/null || true)

if [ -z "${MGMT_HOST}" ]; then
  echo "Management route not found. Did you run demo-up?" >&2
  exit 1
fi

USER=$(oc get secret jboss-admin -n "${NS}" -o jsonpath='{.data.username}' 2>/dev/null | base64 -d || echo admin)
PASS=$(oc get secret jboss-admin -n "${NS}" -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo 'Admin#123')

URL="https://${MGMT_HOST}"
echo "JBoss Admin Console: ${URL}"
echo "App:                 https://${APP_HOST}"
echo "Username: ${USER}"
echo "Password: ${PASS}"
echo
echo "Open the Console URL in your browser (DevSpaces: Ctrl/Cmd+click)."

if command -v xdg-open >/dev/null; then
  xdg-open "${URL}" >/dev/null 2>&1 || true
elif command -v open >/dev/null; then
  open "${URL}" >/dev/null 2>&1 || true
fi

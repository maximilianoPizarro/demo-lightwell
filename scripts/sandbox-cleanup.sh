#!/usr/bin/env bash
# Free Developer Sandbox quota: idle workspaces, failed pods, unused PVCs (careful)
set -euo pipefail

NS_DEV="${1:-$(oc project -q 2>/dev/null || true)}"
if [ -z "${NS_DEV}" ]; then
  echo "Usage: $0 <namespace>" >&2
  exit 1
fi

echo "Cleaning namespace ${NS_DEV} ..."
oc delete pod --field-selector=status.phase=Failed -n "${NS_DEV}" --ignore-not-found=true || true
oc delete pod --field-selector=status.phase=Succeeded -n "${NS_DEV}" --ignore-not-found=true || true

# Stop DevWorkspaces if present (free memory)
if oc api-resources | grep -q devworkspaces; then
  oc get devworkspaces -n "${NS_DEV}" -o name 2>/dev/null | while read -r dw; do
    echo "Stopping ${dw}"
    oc patch "${dw}" -n "${NS_DEV}" --type merge -p '{"spec":{"started":false}}' || true
  done
fi

echo "Quota snapshot:"
oc get resourcequota,pvc,pod -n "${NS_DEV}" 2>/dev/null || true
echo "Done. Review PVCs manually before deleting: oc get pvc -n ${NS_DEV}"

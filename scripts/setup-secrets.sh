#!/usr/bin/env bash
# Create GitHub + OpenShift secrets for the demo (reads env or prompts)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

need() { eval "v=\${$1:-}"; if [ -z "$v" ]; then echo "Missing $1" >&2; exit 1; fi; }

need LIGHTWELL_USERNAME
need LIGHTWELL_TOKEN
need QUAY_USERNAME
need QUAY_PASSWORD

QUAY_IMAGE="${QUAY_IMAGE:-quay.io/maximilianopizarro/demo-lightwell}"
LIGHTWELL_TIER="${LIGHTWELL_TIER:-validated}"
JBOSS_ADMIN_USER="${JBOSS_ADMIN_USER:-admin}"
JBOSS_ADMIN_PASSWORD="${JBOSS_ADMIN_PASSWORD:-Admin#123}"

NS_DEV="${NS_DEV:-$(oc project -q 2>/dev/null || echo "")}"
NS_DS="${NS_DS:-}"
if [ -n "${NS_DEV}" ] && [ -z "${NS_DS}" ]; then
  # Developer Sandbox pattern: user-dev + user-devspaces
  NS_DS="${NS_DEV%-dev}-devspaces"
  if [[ "${NS_DEV}" == *-dev ]]; then
    NS_DS="${NS_DEV%-dev}-devspaces"
  fi
fi

echo "Setting GitHub secrets on origin repo..."
if command -v gh >/dev/null; then
  printf '%s' "${LIGHTWELL_USERNAME}" | gh secret set LIGHTWELL_USERNAME
  printf '%s' "${LIGHTWELL_TOKEN}" | gh secret set LIGHTWELL_TOKEN
  printf '%s' "${QUAY_USERNAME}" | gh secret set QUAY_USERNAME
  printf '%s' "${QUAY_PASSWORD}" | gh secret set QUAY_PASSWORD
  printf '%s' "${QUAY_IMAGE}" | gh secret set QUAY_IMAGE
  printf '%s' "${LIGHTWELL_TIER}" | gh secret set LIGHTWELL_TIER
  echo "GitHub secrets set."
else
  echo "gh not found — skip GitHub secrets"
fi

apply_ns() {
  local ns="$1"
  [ -n "$ns" ] || return 0
  if ! oc get ns "$ns" >/dev/null 2>&1; then
    echo "Namespace $ns not found — skip"
    return 0
  fi
  echo "Applying secrets to ${ns}..."
  oc create secret generic lightwell-sa \
    --from-literal=username="${LIGHTWELL_USERNAME}" \
    --from-literal=token="${LIGHTWELL_TOKEN}" \
    -n "${ns}" --dry-run=client -o yaml | oc apply -f -
  oc create secret generic jboss-admin \
    --from-literal=username="${JBOSS_ADMIN_USER}" \
    --from-literal=password="${JBOSS_ADMIN_PASSWORD}" \
    -n "${ns}" --dry-run=client -o yaml | oc apply -f -
  oc create secret generic quay-creds \
    --from-literal=username="${QUAY_USERNAME}" \
    --from-literal=password="${QUAY_PASSWORD}" \
    -n "${ns}" --dry-run=client -o yaml | oc apply -f -
  oc create secret docker-registry quay-pull-secret \
    --docker-server=quay.io \
    --docker-username="${QUAY_USERNAME}" \
    --docker-password="${QUAY_PASSWORD}" \
    -n "${ns}" --dry-run=client -o yaml | oc apply -f -
  oc create secret generic lightwell-devspaces-env \
    --from-literal=LIGHTWELL_USERNAME="${LIGHTWELL_USERNAME}" \
    --from-literal=LIGHTWELL_TOKEN="${LIGHTWELL_TOKEN}" \
    --from-literal=LIGHTWELL_TIER="${LIGHTWELL_TIER}" \
    --from-literal=LIGHTWELL_URL="${LIGHTWELL_URL:-https://packages.redhat.com/api/pulp-content/public-lightwell-demo/java/validated/}" \
    --from-literal=QUAY_IMAGE="${QUAY_IMAGE}" \
    -n "${ns}" --dry-run=client -o yaml | oc apply -f -
  # DevSpaces auto-mount labels
  oc label secret lightwell-devspaces-env \
    controller.devfile.io/mount-to-devworkspace=true \
    controller.devfile.io/watch-secret=true \
    -n "${ns}" --overwrite || true
  oc annotate secret lightwell-devspaces-env \
    controller.devfile.io/mount-as=env \
    -n "${ns}" --overwrite || true
}

if [ -n "${NS_DEV}" ]; then
  apply_ns "${NS_DEV}"
fi
if [ -n "${NS_DS}" ]; then
  apply_ns "${NS_DS}"
fi

echo "Done. Rotate tokens that were shared in chat after this demo setup."

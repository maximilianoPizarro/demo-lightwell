#!/usr/bin/env bash
# Resolve Lightwell URL / server id from LIGHTWELL_TIER
set -euo pipefail

TIER="${LIGHTWELL_TIER:-validated}"
case "${TIER}" in
  remediated)
    export LIGHTWELL_SERVER_ID="${LIGHTWELL_SERVER_ID:-lightwell-remediated}"
    export LIGHTWELL_URL="${LIGHTWELL_URL:-https://packages.redhat.com/lightwell/java/remediated/}"
    export LIGHTWELL_REPO_NAME="${LIGHTWELL_REPO_NAME:-maven-lightwell-remediated}"
    ;;
  validated-prod)
    export LIGHTWELL_SERVER_ID="${LIGHTWELL_SERVER_ID:-lightwell-validated}"
    export LIGHTWELL_URL="${LIGHTWELL_URL:-https://packages.redhat.com/lightwell/java/validated/}"
    export LIGHTWELL_REPO_NAME="${LIGHTWELL_REPO_NAME:-maven-lightwell-validated}"
    ;;
  validated|*)
    export LIGHTWELL_SERVER_ID="${LIGHTWELL_SERVER_ID:-lightwell-validated}"
    export LIGHTWELL_URL="${LIGHTWELL_URL:-https://packages.redhat.com/api/pulp-content/public-lightwell-demo/java/validated/}"
    export LIGHTWELL_REPO_NAME="${LIGHTWELL_REPO_NAME:-maven-lightwell-validated}"
    ;;
esac

echo "LIGHTWELL_TIER=${TIER}"
echo "LIGHTWELL_SERVER_ID=${LIGHTWELL_SERVER_ID}"
echo "LIGHTWELL_URL=${LIGHTWELL_URL}"

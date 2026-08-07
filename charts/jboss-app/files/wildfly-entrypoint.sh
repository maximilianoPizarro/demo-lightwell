#!/usr/bin/env bash
# WildFly start wrapper: allow HAL browser Origin (OpenShift edge Route HTTPS).
# Without allowed-origins, /management returns 403 when the console sends Origin.
set -euo pipefail

CFG="${WILDFLY_CONFIG:-/opt/jboss/wildfly/standalone/configuration/standalone.xml}"
ORIGINS="${MANAGEMENT_ALLOWED_ORIGINS:-}"

if [[ -n "${ORIGINS}" && -f "${CFG}" ]]; then
  # WildFly accepts a space-separated list in the allowed-origins attribute.
  ORIGINS_NORM="$(printf '%s' "${ORIGINS}" | tr ',' ' ' | xargs)"
  if grep -q 'allowed-origins=' "${CFG}"; then
    sed -i -E "s|allowed-origins=\"[^\"]*\"|allowed-origins=\"${ORIGINS_NORM}\"|" "${CFG}"
  else
    sed -i -E "s|(<http-interface[^>]*http-authentication-factory=\"[^\"]*\")|\\1 allowed-origins=\"${ORIGINS_NORM}\"|" "${CFG}"
  fi
  echo "Configured management allowed-origins: ${ORIGINS_NORM}"
fi

exec /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 "$@"

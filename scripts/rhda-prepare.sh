#!/usr/bin/env bash
# Prepare Dev Spaces workspace so Red Hat Dependency Analytics (RHDA / TPA) can
# resolve Lightwell artifacts via Nexus and write the HTML report under .rhda/.
# The report UI itself is opened by the VS Code extension — not by this script.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

RHDA_DIR="${ROOT}/.rhda"
REPORT="${RHDA_DIR}/redhatDependencyAnalyticsReport.html"
M2_DIR="${ROOT}/.m2"
SETTINGS="${M2_DIR}/settings.xml"
TEMPLATE="${ROOT}/settings/maven-devspaces.xml.template"
HOME_M2="${HOME}/.m2"
HOME_SETTINGS="${HOME_M2}/settings.xml"

mkdir -p "${RHDA_DIR}" "${M2_DIR}" "${HOME_M2}"
: > "${RHDA_DIR}/.gitkeep"
touch "${REPORT}"

resolve_nexus_url() {
  local ns host svc
  if [[ -n "${NEXUS_MAVEN_PUBLIC_URL:-}" ]]; then
    echo "${NEXUS_MAVEN_PUBLIC_URL}"
    return
  fi
  if command -v oc >/dev/null 2>&1; then
    ns="$(oc project -q 2>/dev/null || true)"
    # Workspace may be in *-devspaces; Nexus lives in *-dev
    if [[ "${ns}" == *-devspaces ]]; then
      ns="${ns%-devspaces}-dev"
    fi
    host="$(oc get route nexus -n "${ns}" -o jsonpath='{.spec.host}' 2>/dev/null || true)"
    if [[ -n "${host}" ]]; then
      echo "https://${host}/repository/maven-public/"
      return
    fi
    svc="http://nexus.${ns}.svc:8081/repository/maven-public/"
    if curl -sf -o /dev/null --connect-timeout 2 "${svc}" 2>/dev/null; then
      echo "${svc}"
      return
    fi
  fi
  # Same-namespace fallback (umbrella install in current project)
  echo "http://nexus:8081/repository/maven-public/"
}

NEXUS_URL="$(resolve_nexus_url)"
echo "==> Nexus Maven public: ${NEXUS_URL}"

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "ERROR: missing ${TEMPLATE}" >&2
  exit 1
fi

sed "s|__NEXUS_MAVEN_PUBLIC_URL__|${NEXUS_URL}|g" "${TEMPLATE}" > "${SETTINGS}"
cp -f "${SETTINGS}" "${HOME_SETTINGS}"
echo "==> Wrote Maven settings:"
echo "    ${SETTINGS}"
echo "    ${HOME_SETTINGS}"

MVN_BIN="$(command -v mvn || true)"
if [[ -z "${MVN_BIN}" ]]; then
  for c in \
    /home/user/.sdkman/candidates/maven/current/bin/mvn \
    /usr/bin/mvn \
    /usr/local/bin/mvn; do
    [[ -x "${c}" ]] && MVN_BIN="${c}" && break
  done
fi

if [[ -n "${MVN_BIN}" ]]; then
  echo "==> Maven: ${MVN_BIN}"
  # Warm the tree RHDA will need (fails loud if Nexus/Lightwell unreachable)
  if ! "${MVN_BIN}" -s "${SETTINGS}" -f app/pom.xml -q dependency:resolve -DincludeArtifactIds=commons-io,commons-fileupload; then
    echo "WARN: Maven could not resolve Lightwell deps via Nexus." >&2
    echo "      RHDA report may stay empty until Nexus + Lightwell proxy are up." >&2
    echo "      Run: demo-up   then retry analyze-cves." >&2
  else
    echo "==> Maven resolved Lightwell artifacts (commons-io / commons-fileupload)."
    "${MVN_BIN}" -s "${SETTINGS}" -f app/pom.xml dependency:tree -Dverbose=false || true
  fi
  echo "${MVN_BIN}" > "${RHDA_DIR}/mvn.path"
else
  echo "WARN: mvn not found on PATH — RHDA needs Maven to analyze pom.xml" >&2
fi

# Focus the manifest in the IDE when the Che/VS Code CLI is available
if command -v code >/dev/null 2>&1; then
  code -r -g "${ROOT}/app/pom.xml:1" >/dev/null 2>&1 || true
elif command -v code-server >/dev/null 2>&1; then
  code-server -r -g "${ROOT}/app/pom.xml:1" >/dev/null 2>&1 || true
fi

cat <<EOF

========================================================================
RHDA report is NOT printed in this terminal.

The HTML report is written to:
  ${REPORT}

Open it from the IDE (extension redhat.fabric8-analytics):

  1) Confirm Java is in Standard mode (status bar → not Lightweight).
  2) Open app/pom.xml in the editor (should be focused now).
  3) Wait for inline Component Analysis (wavy underlines on versions), OR
  4) Command Palette (Ctrl+Shift+P) →
       "Red Hat Dependency Analytics Report"
     — or right-click app/pom.xml in Explorer → same command
     — or click the pie-chart icon on the pom editor title bar
  5) If nothing opens: View → Output → select "Red Hat Dependency Analytics"

Workspace settings (.vscode/settings.json) point reportFilePath at .rhda/
and Maven userSettings at .m2/settings.xml (Nexus → Lightwell).
========================================================================
EOF

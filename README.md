# demo-lightwell

[![License](https://img.shields.io/badge/license-Apache%202.0-blue?style=flat-square)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-222?style=flat-square)](https://maximilianopizarro.github.io/demo-lightwell/)
[![Helm](https://img.shields.io/badge/Helm-charts-0F1689?style=flat-square&logo=helm&logoColor=white)](https://maximilianopizarro.github.io/demo-lightwell/charts/)
[![Artifact Hub](https://img.shields.io/badge/Artifact%20Hub-ready-417598?style=flat-square)](https://artifacthub.io/packages/search?repo=demo-lightwell)
[![OpenShift Dev Spaces](https://img.shields.io/badge/OpenShift-Dev%20Spaces-EE0000?style=flat-square)](https://developers.redhat.com/products/openshift-dev-spaces)
[![OpenShift Pipelines](https://img.shields.io/badge/OpenShift-Pipelines-EE0000?style=flat-square)](https://www.redhat.com/en/technologies/cloud-computing/openshift/pipelines)
[![Quay](https://img.shields.io/badge/Quay-contingency-40B4E5?style=flat-square)](https://www.redhat.com/en/technologies/cloud-computing/quay)
[![Lightwell](https://img.shields.io/badge/Lightwell-validated%20demo-EE0000?style=flat-square)](https://www.redhat.com/en/lightwell)

<p align="center">
  <img src="docs/brand/lightwell_logo_light.svg" alt="Official Lightwell logo" width="360" />
</p>

<p align="center">
  <img src="docs/brand/openshift-dev-spaces.svg" alt="OpenShift Dev Spaces" height="48" />
  &nbsp;&nbsp;
  <img src="docs/brand/openshift-pipelines.svg" alt="OpenShift Pipelines" height="48" />
  &nbsp;&nbsp;
  <img src="docs/brand/quay.svg" alt="Red Hat Quay" height="48" />
</p>

Lightwell Java demo for **OpenShift Dev Spaces** on Developer Sandbox: legacy WAR → **Nexus** (PVC) proxy → Lightwell **validated** demo registry, CVEs via **Red Hat Dependency Analytics** (TPA/TDA), **OpenShift Pipelines (Tekton)** + **Quay**, and a **GitHub Actions** contingency path that builds **without Nexus**.

## 🚀 Quick Start: Open in Red Hat OpenShift Dev Spaces

[![Open in Dev Spaces](https://img.shields.io/badge/Open_in-Dev_Spaces-EE0000?logo=redhat&style=for-the-badge)](https://workspaces.openshift.com/#https://github.com/maximilianoPizarro/demo-lightwell)

Clicking the badge above leverages the **Dev Spaces Factory URL** to automatically provision a complete cloud development environment directly in your Red Hat Developer Sandbox.

- **Zero-Install Setup:** It reads the repository's `.devfile.yaml` to spin up a Red Hat Universal Developer Image (UDI) container with OpenJDK 17.
- **Security Tooling Pre-configured:** Automatically installs the **Red Hat Dependency Analytics (RHDA)** VS Code extension, allowing instant Trusted Profile Analyzer (TPA) / Trusted Dependency Analyzer (TDA) CVE scanning directly in your IDE.
- **One-Click Execution:** Exposes custom IDE tasks (`demo-up`, `open-jboss-console`) to deploy Nexus, proxy Lightwell, and run the Tekton pipeline without touching a local terminal.

---

## Documentation

| Resource | Link |
|----------|------|
| **Site (GitHub Pages)** | https://maximilianopizarro.github.io/demo-lightwell/ |
| Developer journey (3 steps) | [docs/JOURNEY.md](docs/JOURNEY.md) |
| Remediated switch (subscription) | [docs/JOURNEY-REMEDIATED.md](docs/JOURNEY-REMEDIATED.md) |
| Architecture | [docs/lightwell-architecture.png](docs/lightwell-architecture.png) |
| Brand / logos attribution | [docs/brand/ATTRIBUTION.md](docs/brand/ATTRIBUTION.md) |
| Lightwell product | https://www.redhat.com/en/lightwell |
| Configure Maven (Lightwell) | https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_java_build_tool |
| Configure Nexus (Lightwell) | https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_nexus_to_use_rhln_repository |
| Trusted Profile Analyzer / RHDA | https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/1/html/quick_start_guide/configuring-visual-studio-code-to-use-dependency-analytics_qsg |
| Design tokens (ux.redhat.com) | https://ux.redhat.com/tokens/color/ |
| Artifact Hub (register charts URL) | `https://maximilianopizarro.github.io/demo-lightwell/charts` |

## Artifact Hub

1. Publish GitHub Pages (workflow `.github/workflows/pages-charts.yml`).
2. On [Artifact Hub](https://artifacthub.io/), add a **Helm charts** repository:
   - URL: `https://maximilianopizarro.github.io/demo-lightwell/charts`
3. Copy the repository ID into [`artifacthub-repo.yml`](artifacthub-repo.yml) (`repositoryID`) for Verified Publisher.

Charts include Artifact Hub annotations in `charts/*/Chart.yaml` (links, category, screenshots, license).

```bash
helm repo add demo-lightwell https://maximilianopizarro.github.io/demo-lightwell/charts
helm repo update
# Recommended: one umbrella install (secrets + Nexus + JBoss + Tekton)
helm install demo demo-lightwell/demo-lightwell
# Or install subcharts individually:
# helm install nexus demo-lightwell/nexus
# helm install jboss-app demo-lightwell/jboss-app
```

## Layout

```
app/                         Maven WAR (Lightwell commons-io / commons-fileupload)
charts/demo-lightwell/       Umbrella chart (secrets + Nexus + JBoss + Tekton)
charts/nexus/                Thin Nexus OSS + PVC + Lightwell configure Job
charts/jboss-app/            WildFly/JBoss deploy + app & management Routes
charts/devspaces-workspace/  Optional DevWorkspace CR via Helm/GitOps
pipelines/                   Tekton Pipeline reference (also in umbrella templates)
.github/workflows/           Release image (GHCR) + GitHub Pages / Helm index
.devfile.yaml                demo-up / analyze-cves / open-jboss-console
docs/                        Pages site, journeys, brand logos
scripts/                     demo-up, cleanup, tier helpers
artifacthub-repo.yml         Artifact Hub repository metadata
```

## Fork: edit values, then one Helm install

After forking, edit **only** [`charts/demo-lightwell/values.yaml`](charts/demo-lightwell/values.yaml):

| Key | Purpose |
|-----|---------|
| `lightwell.username` | `id\|account` service account |
| `lightwell.token` | SA JWT |
| `quay.username` / `quay.password` | Quay robot |
| `quay.image` + `jboss-app.image.repository` | Your Quay image path |

```bash
helm dependency update charts/demo-lightwell
NS=$(oc project -q)
helm upgrade --install demo charts/demo-lightwell --wait --timeout 12m \
  --set jboss-app.image.repository=image-registry.openshift-image-registry.svc:5000/$NS/demo-lightwell \
  --set 'jboss-app.image.pullSecrets={}'
```

On install the chart also:

- Starts a Tekton **PipelineRun** that builds/pushes to the **OpenShift internal registry** (default)
- Creates a **DevWorkspace** in `*-devspaces`
- Optionally pushes to Quay with `--set quay.push=true` (+ credentials)

Optional: `scripts/setup-secrets.sh` remains for standalone / GitHub Secrets setup without the umbrella chart.

## DevSpaces

[![Open in Dev Spaces](https://img.shields.io/badge/Open_in-Dev_Spaces-EE0000?logo=redhat&style=for-the-badge)](https://workspaces.openshift.com/#https://github.com/maximilianoPizarro/demo-lightwell)

1. Click the badge above to create a workspace from this Git repository (or alternatively, deploy the `devspaces-workspace` Helm chart).
2. Ensure `charts/demo-lightwell/values.yaml` has your credentials (no `CHANGE_ME`).
3. Run **demo-up** (umbrella Helm install).
4. Open `app/pom.xml` → Red Hat Dependency Analytics Report.
5. Run **open-jboss-console**.

## Quay contingency image

GitHub Actions and local `podman push` target `quay.io/maximilianopizarro/demo-lightwell:contingency`.

If push fails with **authentication required** / empty robot `actions`, create the repository in the Quay UI and grant robot `maximilianopizarro+quaydevfile` **Write**. Until then, use the in-cluster build:

```bash
oc apply -f k8s/openshift-build.yaml
oc start-build demo-lightwell --from-dir=. --follow
helm upgrade --install jboss-app ./charts/jboss-app \
  --set image.repository=image-registry.openshift-image-registry.svc:5000/$(oc project -q)/demo-lightwell \
  --set image.tag=contingency \
  --set image.pullSecrets={}
```

## License / demo notice

Apache-2.0. Demo content targets Red Hat Lightwell **public demo** validated index. Trademarks remain with their owners — see [docs/brand/ATTRIBUTION.md](docs/brand/ATTRIBUTION.md). For production remediated tier see [JOURNEY-REMEDIATED.md](docs/JOURNEY-REMEDIATED.md). Rotate any credentials that were shared in chat after setup.

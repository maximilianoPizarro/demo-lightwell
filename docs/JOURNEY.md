# Lightwell Java Demo — Journey (validated)

Focus: **secure development** for legacy Java — remediate vulnerable third-party deps with **Red Hat Lightwell Network**, surface **CVEs** in the IDE (RHDA / Trusted Profile Analyzer), and build/deploy on OpenShift.

## Story

1. A legacy JBoss/WildFly WAR depends on third-party libraries with known CVEs.
2. **Lightwell** provides a validated Maven repository of remediations (demo tier: `public-lightwell-demo/.../validated/`).
3. **Nexus** (thin chart + PVC) proxies Lightwell with a **service account** — the enterprise pattern.
4. **OpenShift Dev Spaces** opens this repo ([factory URL](https://workspaces.openshift.com/#https://github.com/maximilianoPizarro/demo-lightwell)); Maven resolves via Nexus; **RHDA** shows CVEs on `pom.xml`.
5. **Tekton** builds through Nexus→Lightwell and deploys the app (optional Quay push from the cluster).
6. **GitHub Actions** on `main` publishes to **Quay** (`latest` / `contingency` / `sha-…`); **GHCR** is the public fallback.
7. Open the **app home** and the **WildFly management console**.

## Architecture

![Architecture](lightwell-architecture.png)

## Visual journey

| Step | What you see |
|------|----------------|
| 1. Developer Sandbox | ![Developer Sandbox](journey/01-developer-sandbox.png) |
| 2. OpenShift Topology | ![Topology](journey/02-openshift-topology.png) |
| 3. Nexus → Lightwell validated | ![Nexus](journey/04-nexus-lightwell-validated.png) |
| 4. Lightwell validated registry | ![Lightwell](journey/05-lightwell-validated-registry.png) |
| 5. Tekton PipelineRun | ![PipelineRuns](journey/06-tekton-pipelineruns.png) |
| 6. JBoss app home | ![App home](journey/07-jboss-app-home.png) |
| 7. Dev Spaces — RHDA plugin | ![RHDA](journey/08-devspaces-rhda-plugins.png) |
| 7b. Devfile commands (analyze-cves) | ![Commands](journey/08b-devspaces-devfile-commands.png) |
| 8. OpenShift Pipelines detail | ![Pipeline detail](journey/09b-pipelinerun-detail.png) |
| 8b. Tekton maven logs → Nexus `commons-io` `.rhlw` | ![Maven Nexus commons-io](journey/09c-tekton-maven-nexus-commons-io.png) |
| 8c. Tekton maven logs → Nexus `.rhlw` jars | ![Maven Nexus jars](journey/09d-tekton-maven-nexus-jars.png) |
| 9. Quay image tags (`latest` / `contingency`) | ![Quay](journey/10-quay-tags.png) (carousel falls back to [GHCR](journey/10-ghcr-image-tags.png) if missing) |
| 10. Artifact Hub charts | ![Artifact Hub](journey/11-artifacthub-charts.png) |
| 10b. Artifact Hub Security Report (image summary) | ![Security CVEs](journey/11b-artifacthub-security-cves.png) |
| 11. Stock commons-io CVE (not Lightwell GAV) | ![CVE-2024-47554](journey/12-artifacthub-commons-io-cve-stock.png) |
| 12. RHDA Dependency Analytics Report | ![RHDA report](journey/13-rhda-dependency-analytics-report.png) |
| 13. HAL server.log (`ROOT.war` deployed) | ![HAL server.log](journey/15-hal-server-log.png) |

## Proof: Artifact Hub vs Lightwell vs RHDA

**Do not expect RHDA to be all-green** just because deps are `*.rhlw-00001` from the public **validated** demo repo.

| Tool | Looks at | Expected demo signal |
|------|----------|----------------------|
| [Artifact Hub Security Report](https://artifacthub.io/packages/helm/demo-lightwell/jboss-app?modal=security-report) | Chart image `wildfly:27.0.1…` | Stock `commons-io:2.11.0` → CVE-2024-47554 |
| Nexus / `/health` | Resolved Maven jars | App uses `2.11.0.rhlw-00001` |
| RHDA / TPA | `pom.xml` + OSV + Red Hat remediations | Still **Direct Vulnerabilities** on `.rhlw` rows; green line = **remediations available**, not zero CVEs |

```xml
<!-- app/pom.xml — Lightwell coordinate (validated demo) -->
<version>2.11.0.rhlw-00001</version>
```

See the [RHDA report screenshot](journey/13-rhda-dependency-analytics-report.png) (also on Pages `#rhda`).

Validated demo = trusted Lightwell **path** for the sandbox. Clearing OSV findings is the product path ([validated → remediated](JOURNEY-REMEDIATED.md) with subscription).
Factory URL (Eclipse Che hosted by Red Hat / Developer Sandbox):

```text
https://workspaces.openshift.com/#https://github.com/maximilianoPizarro/demo-lightwell
```

App & console (after deploy):

```text
App:      https://jboss-app-<ns>.apps.../
Console:  https://jboss-app-mgmt-<ns>.apps.../console
          user: admin   password: Admin#123  (Secret jboss-admin)
```

## Beyond this demo (production)

This demo stops at **validated deps + CVE visibility + build/deploy**. In a production secure SDLC you should also plan for:

- **SBOM** generation (e.g. CycloneDX / SPDX) from the Maven build and container image
- **SLSA** provenance for builds (attestation that the artifact came from a trusted pipeline)

Integrating **SLSA with SBOM** (signing, attestation storage, policy gates in admission) is **out of scope for this demo**, but it is the natural next step once Lightwell remediations and RHDA are in place.

## Fork → edit values → one Helm install

After forking, edit [`charts/demo-lightwell/values.yaml`](../charts/demo-lightwell/values.yaml) (Lightwell SA; Quay optional):

```bash
helm dependency update charts/demo-lightwell
NS=$(oc project -q)
helm upgrade --install demo charts/demo-lightwell --wait --timeout 12m \
  --set jboss-app.image.repository=image-registry.openshift-image-registry.svc:5000/$NS/demo-lightwell \
  --set jboss-app.image.tag=latest \
  --set 'jboss-app.image.pullSecrets={}'
```

Or open Dev Spaces and run the Devfile task **demo-up**.

## Developer steps

| Step | Action | Security outcome |
|------|--------|------------------|
| 0 | Open workspace via factory URL | Cloud IDE + RHDA extension |
| 1 | **demo-up** / Helm install | Nexus proxy with Lightwell SA + app |
| 2 | Run **analyze-cves** (prepares Nexus Maven settings + `.rhda/` report path), then in the IDE: open `app/pom.xml` → Command Palette → **Red Hat Dependency Analytics Report** | HTML report tab (RHDA / TPA); terminal alone never shows the report |
| 3 | Browse Nexus `maven-lightwell-validated` | Confirmed `.rhlw` artifacts |
| 4 | Open app `/` and mgmt console | Runtime check |

## Related

- Day-2 subscription path: [JOURNEY-REMEDIATED.md](JOURNEY-REMEDIATED.md)
- [Configure Maven (Lightwell)](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_java_build_tool)
- [Configure Nexus for Lightwell](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_nexus_to_use_rhln_repository)
- [SLSA](https://slsa.dev/) · [CycloneDX SBOM](https://cyclonedx.org/) (production follow-ups)

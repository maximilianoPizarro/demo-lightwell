# Journey: validated (demo) → remediated (subscription)

Use this checklist when the organization has an active **Lightwell Network** membership and should consume the **remediated** tier (artifacts with `.rhlw-*` suffixes) instead of the public demo **validated** index.

Official references:

- [Configure Java build tool](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_java_build_tool)
- [Configure Nexus](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_nexus_to_use_rhln_repository)

## Conceptual switch

| | Demo (this repo default) | With subscription |
|--|--------------------------|-------------------|
| Tier | Validated (demo pulp) | **Remediated** |
| URL | `https://packages.redhat.com/api/pulp-content/public-lightwell-demo/java/validated/` | `https://packages.redhat.com/lightwell/java/remediated/` |
| Server id | `lightwell-validated` | `lightwell-remediated` |
| SA | Demo service account | Org service account (`XXXXXXX\|name`) |
| Verify | Deps resolve from validated | Deps resolve + `.rhlw-0000X` on remediated artifacts |

## Process

1. **Confirm subscription** — Lightwell Network membership active.
2. **Create org service account** — username `XXXXXXX|service-account-name` + token.
3. **Rotate secrets** — update `LIGHTWELL_USERNAME` / `LIGHTWELL_TOKEN` in GitHub Secrets and OpenShift (`lightwell-sa`, `lightwell-devspaces-env`). Set `LIGHTWELL_TIER=remediated`.
4. **Repoint Nexus** — remote URL to remediated, Layout Policy **Strict**, new SA auth. Helper:

   ```bash
   export LIGHTWELL_TIER=remediated
   export LIGHTWELL_USERNAME='...'
   export LIGHTWELL_TOKEN='...'
   export NEXUS_ADMIN_PASSWORD='admin123'
   bash scripts/configure-nexus-lightwell.sh
   ```

   Or Helm values:

   ```yaml
   lightwell:
     tier: remediated
     remoteUrl: https://packages.redhat.com/lightwell/java/remediated/
     repositoryName: maven-lightwell-remediated
   ```

5. **Maven / GHA** — `LIGHTWELL_TIER=remediated` makes `scripts/lightwell-env.sh` and the contingency workflow use `lightwell-remediated` + product URL.
6. **DevSpaces** — no journey change for developers; ConfigMap/Nexus mirror should target `maven-lightwell-remediated`.
7. **Verify**:

   ```bash
   bash scripts/render-maven-settings.sh
   mvn -f app/pom.xml -s app/settings-lightwell-direct.xml dependency:resolve
   # Expect artifacts from .../remediated/ and versions like 2.11.0.rhlw-00001
   ```

8. **Re-scan RHDA** on `app/pom.xml`, then rebuild (GHA + Tekton) and redeploy.

## Notes

- Demo default stays **validated** / public-lightwell-demo so the sandbox journey works without a paid membership.
- Switching tier is configuration-only (`LIGHTWELL_TIER` + secrets + Nexus remote URL).

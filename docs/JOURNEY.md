# Lightwell Java Demo — Journey (validated)

## Story

1. A legacy JBoss-style WAR depends on third-party Java libraries with known CVEs.
2. **Lightwell** provides a validated Maven repository of remediations (demo tier: `public-lightwell-demo/.../validated/`).
3. **Nexus** (thin chart + PVC) proxies Lightwell with a service account — the enterprise pattern.
4. **DevSpaces** opens this repo; Maven resolves via Nexus; **Red Hat Dependency Analytics** (Trusted Profile Analyzer / Trusted Dependency Analytics) shows CVEs on `pom.xml`.
5. **GitHub Actions** validates Lightwell **without Nexus** and publishes a **`:contingency`** image to Quay.
6. **Tekton** (optional) builds `:latest` through Nexus and deploys.
7. Open the **JBoss/WildFly admin console** from the workspace.

## Architecture

![Architecture](lightwell-architecture.png)

## Developer steps (3 actions)

| Step | Devfile command | What happens |
|------|-----------------|--------------|
| 0 | Create Workspace from this Git repo | Devfile + RHDA extension |
| 1 | **demo-up** | Helm Nexus + JBoss (`:contingency` or Tekton `:latest`) |
| 2 | Open `app/pom.xml` → **Red Hat Dependency Analytics Report** | CVEs via TPA/TDA |
| 3 | **open-jboss-console** | Prints/opens management Route |

### After demo-up you should see

```text
App:      https://jboss-app-....apps...
Console:  https://jboss-app-mgmt-....apps...
Nexus:    https://nexus-....apps...
Next:     open app/pom.xml → RHDA report → task open-jboss-console
```

## One-time setup (demo owner)

```bash
oc login --token=... --server=https://api....openshiftapps.com:6443
export LIGHTWELL_USERNAME='XXXXXXX|demo-account'
export LIGHTWELL_TOKEN='...'
export QUAY_USERNAME='maximilianopizarro+quaydevfile'
export QUAY_PASSWORD='...'
bash scripts/sandbox-cleanup.sh "$(oc project -q)"
bash scripts/setup-secrets.sh
```

Then push to `main` so GitHub Actions publishes `:contingency`, or build locally and push to Quay.

## Related

- Day-2 subscription path: [JOURNEY-REMEDIATED.md](JOURNEY-REMEDIATED.md)
- Product docs: [Configure Maven](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_java_build_tool), [Configure Nexus](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_nexus_to_use_rhln_repository)

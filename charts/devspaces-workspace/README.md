# devspaces-workspace

Helm chart that creates a **DevWorkspace** CR for the Lightwell Java demo on **OpenShift Dev Spaces**.

## What it deploys

- `DevWorkspace` pointing at this Git repository / factory URL
- Workspace commands aligned with the repo `.devfile.yaml` (`demo-up`, `analyze-cves`, `open-jboss-console`)

## Why it exists

So the cloud IDE can be provisioned via Helm/GitOps the same way as Nexus and the app, instead of only using the factory link manually.

## Prefer the factory URL for humans

```text
https://workspaces.openshift.com/#https://github.com/maximilianoPizarro/demo-lightwell
```

Inside the workspace:

1. Run **demo-up** (or use the umbrella chart)
2. Run **analyze-cves** (Maven settings + RHDA prep), then open `app/pom.xml` → **Red Hat Dependency Analytics Report**
3. Open the JBoss app / HAL console Routes

## Documentation

https://maximilianopizarro.github.io/demo-lightwell/

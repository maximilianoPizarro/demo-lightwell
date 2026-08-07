# nexus

Lightweight **Sonatype Nexus Repository OSS** (single pod + PVC) used as an enterprise-style Maven proxy in front of **Red Hat Lightwell Network**.

## What it deploys

- Nexus 3 Deployment + PVC (demo-sized heap)
- Service + OpenShift Route
- Job that configures a Maven **proxy** repository toward Lightwell (`maven-lightwell-validated` by default) using the Lightwell **service account** on the remote
- Adds that proxy to the `maven-public` group so clients can `mirrorOf *` through one URL

## Why it exists in this demo

Developers and Tekton never call Lightwell with the SA from every Maven client. They talk to Nexus; Nexus authenticates to `packages.redhat.com` with Secret `lightwell-sa`. That is the pattern this chart teaches.

## Default Lightwell remote (validated demo)

```text
https://packages.redhat.com/api/pulp-content/public-lightwell-demo/java/validated/
```

Subscription **remediated** tier is a values change (`lightwell.tier` / `remoteUrl`) — see the Pages day-2 section.

## Access

| Surface | URL |
|---------|-----|
| Nexus UI | `https://nexus-<ns>.apps…/` |
| Maven group | `http://nexus:8081/repository/maven-public/` (in-cluster) |
| Lightwell proxy browse | UI → Browse → `maven-lightwell-validated` |

Demo admin password is set via chart values / Secret (default demo: `admin123`).

## Documentation

https://maximilianopizarro.github.io/demo-lightwell/

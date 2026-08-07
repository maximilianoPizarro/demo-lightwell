# demo-lightwell

Lightwell Java demo for **OpenShift Dev Spaces** on Developer Sandbox: legacy WAR → **Nexus** (PVC) proxy → Lightwell **validated** demo registry, CVEs via **Red Hat Dependency Analytics** (TPA/TDA), **Tekton** + **Quay**, and a **GitHub Actions** contingency path that builds **without Nexus**.

## Quick links

- [Developer journey](docs/JOURNEY.md) (3 DevSpaces steps)
- [Remediated switch (subscription)](docs/JOURNEY-REMEDIATED.md)
- [Architecture diagram](docs/lightwell-architecture.png)

## Layout

```
app/                  Maven WAR (commons-io / commons-fileupload Lightwell versions)
charts/nexus/         Thin Nexus OSS + PVC + Lightwell configure Job
charts/jboss-app/     WildFly/JBoss deploy + app & management Routes
pipelines/            Tekton Pipeline (maven → buildah → helm)
.github/workflows/    Contingency image (Maven → Lightwell direct → Quay :contingency)
.devfile.yaml         demo-up / analyze-cves / open-jboss-console
scripts/              setup-secrets, demo-up, cleanup, tier helpers
```

## Secrets (never commit)

| Name | Purpose |
|------|---------|
| `LIGHTWELL_USERNAME` | `id\|account` service account |
| `LIGHTWELL_TOKEN` | SA token |
| `LIGHTWELL_TIER` | `validated` (default) or `remediated` |
| `QUAY_USERNAME` / `QUAY_PASSWORD` | Quay robot |
| `QUAY_IMAGE` | `quay.io/maximilianopizarro/demo-lightwell` |

```bash
export LIGHTWELL_USERNAME='...'
export LIGHTWELL_TOKEN='...'
export QUAY_USERNAME='...'
export QUAY_PASSWORD='...'
bash scripts/setup-secrets.sh
```

## DevSpaces

1. Create workspace from this Git repository.
2. Run **demo-up**.
3. Open `app/pom.xml` → Red Hat Dependency Analytics Report.
4. Run **open-jboss-console**.

## Quay contingency image

GitHub Actions and local `podman push` target `quay.io/maximilianopizarro/demo-lightwell:contingency`.

If push fails with **authentication required** / empty robot `actions`, create the repository in the Quay UI and grant robot `maximilianopizarro+quaydevfile` **Write**. Until then, use the in-cluster build:

```bash
oc apply -f k8s/openshift-build.yaml
oc start-build demo-lightwell --from-dir=. --follow
helm upgrade --install jboss-app ./charts/jboss-app \
  --set image.repository=image-registry.openshift-image-registry.svc:5000/$(oc project -q)/demo-lightwell \
  --set image.tag=contingency \
  --set image.pullSecrets=null
```

## License / demo notice

Demo content targets Red Hat Lightwell **public demo** validated index. For production remediated tier see [JOURNEY-REMEDIATED.md](docs/JOURNEY-REMEDIATED.md). Rotate any credentials that were shared in chat after setup.

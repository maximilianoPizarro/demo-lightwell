# demo-lightwell (umbrella)

One Helm install for the **Lightwell Java demo** on OpenShift Developer Sandbox / Dev Spaces.

## Components (dependencies)

| Chart | Role |
|-------|------|
| [nexus](../nexus/) | Maven proxy → Lightwell validated (SA on the remote) |
| [jboss-app](../jboss-app/) | WildFly WAR + app Route + HAL console Route |
| (this chart) | Secrets, ImageStream, Tekton Pipeline/PipelineRun, optional DevWorkspace |

## Install (Sandbox)

```bash
# Edit charts/demo-lightwell/values.yaml — lightwell.username / lightwell.token
helm dependency update charts/demo-lightwell
NS=$(oc project -q)
helm upgrade --install demo charts/demo-lightwell --wait --timeout 12m \
  --set jboss-app.image.repository=image-registry.openshift-image-registry.svc:5000/$NS/demo-lightwell \
  --set jboss-app.image.tag=latest \
  --set 'jboss-app.image.pullSecrets={}'
```

Or open Dev Spaces and run the Devfile task **demo-up**.

## What success looks like

- PipelineRun `lightwell-build-deploy-*` **Succeeded**
- App `/` shows `commons-io:2.11.0.rhlw-00001`
- Nexus browse shows Lightwell `.rhlw` artifacts
- RHDA report on `app/pom.xml` (OSV findings + Red Hat remediations available — not “zero CVE”)

## Nexus SA + Maven settings (Tekton)

1. Values `lightwell.username` / `lightwell.token` → Secret `lightwell-sa`.
2. Nexus configure Job creates proxy `maven-lightwell-validated` with that SA on the **remote**, then adds it to group `maven-public`.
3. ConfigMap `maven-settings-lightwell` holds `settings.xml` (`mirrorOf *` → `http://nexus:8081/repository/maven-public/`) — **no** Lightwell password in the client.
4. PipelineRun workspace `maven-settings` mounts that ConfigMap; Task runs `mvn -s …/settings.xml`.

Full narrative: https://maximilianopizarro.github.io/demo-lightwell/#nexus-tekton

## Documentation

End-to-end narrative, RHDA screenshots, Artifact Hub vs Lightwell, console access:  
https://maximilianopizarro.github.io/demo-lightwell/

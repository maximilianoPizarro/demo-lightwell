# Helm charts

After GitHub Pages deploys, this path serves `index.yaml` and packaged charts.

```bash
helm repo add demo-lightwell https://maximilianopizarro.github.io/demo-lightwell/charts
helm repo update
helm search repo demo-lightwell
```

Register the same URL on [Artifact Hub](https://artifacthub.io/) as a Helm charts repository. Place the Artifact Hub repository ID into `artifacthub-repo.yml` for Verified Publisher.

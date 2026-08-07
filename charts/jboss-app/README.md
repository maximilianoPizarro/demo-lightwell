# jboss-app

JBoss / WildFly deployment for the **demo-lightwell** Java WAR on OpenShift.

## What it deploys

- Deployment + Service for the application image (OpenShift internal registry or GHCR `contingency`)
- Route for the **app home** (`/` and `/health`)
- Separate Route for the **HAL management console** (same host serves `/console` and `/management`)
- Entrypoint that sets WildFly `allowed-origins` from `MANAGEMENT_ALLOWED_ORIGINS` (required behind OpenShift edge TLS — otherwise HAL gets `/management` 403)
- Optional Secret reference `jboss-admin` for management credentials

## Why it exists in this demo

The WAR resolves third-party libraries through **Nexus → Red Hat Lightwell** (`*.rhlw-*` Maven coordinates). This chart runs that WAR so you can show:

1. Runtime proof that Lightwell jars are on the classpath (`/health` JSON)
2. WildFly HAL console access for operations demos
3. Artifact Hub **Security Report** on the declared base image (`quay.io/wildfly/wildfly:…`) — a different plane from the app’s Lightwell Maven deps

## Access (Developer Sandbox example)

Replace the host suffix with your cluster / namespace.

| Surface | URL | Credentials |
|---------|-----|-------------|
| App home | `https://jboss-app-<ns>.apps…/` | none |
| Health | `https://jboss-app-<ns>.apps…/health` | none |
| HAL console | `https://jboss-app-mgmt-<ns>.apps…/console` | user `admin` / password from Secret `jboss-admin` (demo default `Admin#123`) |

## Values of interest

| Key | Meaning |
|-----|---------|
| `image.repository` / `image.tag` | App image (prefer ImageStream `demo-lightwell:latest` on Sandbox) |
| `route.management.enabled` | Expose HAL console Route |
| `route.clusterDomain` | Apps domain used to build `https://…-mgmt-…` Origin when host is empty |
| `route.management.allowedOrigins` | Optional override list for WildFly `allowed-origins` |
| `admin.existingSecret` | Secret with `username` + `password` keys |

## Documentation

Full demo narrative (RHDA, Artifact Hub vs Lightwell, Dev Spaces steps):  
https://maximilianopizarro.github.io/demo-lightwell/

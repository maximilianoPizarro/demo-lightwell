{{- define "jboss-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "jboss-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "jboss-app.name" . -}}
{{- end -}}
{{- end -}}

{{- define "jboss-app.labels" -}}
app.kubernetes.io/name: {{ include "jboss-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: demo-lightwell
app.openshift.io/runtime: jboss
{{- end -}}

{{- define "jboss-app.annotations" -}}
app.openshift.io/vcs-uri: https://github.com/maximilianoPizarro/demo-lightwell
app.openshift.io/connects-to: '[{"apiVersion":"apps/v1","kind":"Deployment","name":"nexus"}]'
{{- end -}}

{{/*
HTTPS Origin(s) for WildFly management http-interface allowed-origins.
HAL sends Origin matching the management Route; without this, /management returns 403.
*/}}
{{- define "jboss-app.managementAllowedOrigins" -}}
{{- if .Values.route.management.allowedOrigins -}}
{{- join "," .Values.route.management.allowedOrigins -}}
{{- else -}}
{{- $host := .Values.route.management.host -}}
{{- if not $host -}}
{{- $domain := .Values.route.clusterDomain -}}
{{- if not $domain -}}
{{- $ing := lookup "config.openshift.io/v1" "Ingress" "" "cluster" -}}
{{- if and $ing $ing.spec $ing.spec.domain -}}
{{- $domain = $ing.spec.domain -}}
{{- end -}}
{{- end -}}
{{- if $domain -}}
{{- $host = printf "%s-mgmt-%s.%s" (include "jboss-app.fullname" .) .Release.Namespace $domain -}}
{{- end -}}
{{- end -}}
{{- if $host -}}
{{- printf "https://%s" $host -}}
{{- end -}}
{{- end -}}
{{- end -}}

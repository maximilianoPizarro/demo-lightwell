{{/*
Expand the name of the chart.
*/}}
{{- define "demo-lightwell.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "demo-lightwell.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "demo-lightwell.labels" -}}
helm.sh/chart: {{ include "demo-lightwell.name" . }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "demo-lightwell.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: demo-lightwell
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Dockerconfigjson for Quay pull secret
*/}}
{{- define "demo-lightwell.dockerconfigjson" -}}
{{- $auth := printf "%s:%s" .Values.quay.username .Values.quay.password | b64enc -}}
{{- printf "{\"auths\":{\"quay.io\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .Values.quay.username .Values.quay.password $auth | b64enc -}}
{{- end }}

{{/*
Dev Spaces namespace for the DevWorkspace CR.
Default: release namespace. Sandbox users often lack create rights on *-devspaces
when installing from *-dev, so we do NOT auto-redirect to *-devspaces.
*/}}
{{- define "demo-lightwell.devspacesNamespace" -}}
{{- if .Values.devspaces.namespace -}}
{{- .Values.devspaces.namespace -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end }}

{{/*
Internal image repository (no tag)
*/}}
{{- define "demo-lightwell.internalImage" -}}
{{- printf "image-registry.openshift-image-registry.svc:5000/%s/%s" .Release.Namespace .Values.tekton.imageStream -}}
{{- end }}

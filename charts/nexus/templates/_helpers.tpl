{{- define "nexus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nexus.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "nexus.name" . -}}
{{- end -}}
{{- end -}}

{{- define "nexus.labels" -}}
app.kubernetes.io/name: {{ include "nexus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: demo-lightwell
app.openshift.io/runtime: java
{{- end -}}

{{- define "nexus.annotations" -}}
app.openshift.io/vcs-uri: https://github.com/maximilianoPizarro/demo-lightwell
app.openshift.io/custom-icon: https://raw.githubusercontent.com/maximilianoPizarro/demo-lightwell/main/docs/brand/nexus.png
{{- end -}}

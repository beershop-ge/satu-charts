{{/* vim: set filetype=mustache: */}}
{{/*
  Return the proper image name

  Usage:
    `{{ include "blib.images.image" (dict "imageRoot" .Values.path.to.the.image "context" $) }}`
*/}}
{{- define "common.images.image" }}
    {{- $ := .context -}}

    {{- $registryName := $.Values.global.imageRegistry | default .image.registry | default (regexSplit "/" .image.repository 2 | first) }}
    {{- $repositoryName := .image.repository | trimPrefix (printf "%s/" $registryName) }}
    {{- $termination := printf ":%s" (.image.tag | default $.Chart.AppVersion) }}
    {{- with .image.digest }}
        {{- $termination := printf "@%s" (. | toString) }}
    {{- end }}
    {{- printf "%s/%s%s" $registryName $repositoryName $termination }}
{{- end }}
{{/* vim: set filetype=mustache: */}}
{{/* source: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_labels.tpl */}}
{{/*
  Generate backend entry that is compatible with all Kubernetes API versions.

  Usage:
    `{{ include "common.ingress.backend" (dict "serviceName" "backendName" "servicePort" "backendPort" "context" $) }}`

  Params:
    - serviceName - String. Name of an existing service backend
    - servicePort - String/Int. Port name (or number) of the service. It will be translated to different yaml depending if it is a string or an integer.
    - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "common.ingress.backend" -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}

{{/*
  Return true if cert-manager required annotations for TLS signed
  certificates are set in the Ingress annotations
  Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations

  Usage:
    `{{ include "common.ingress.certManagerRequest" .Values.path.to.the.ingress.annotations }}`
*/}}
{{- define "common.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") (hasKey . "kubernetes.io/tls-acme") }}
    {{- true -}}
{{- end -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* source: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_labels.tpl */}}
{{/*
  Kubernetes standard labels

  Usage:
    `{{ include "common.labels.standard" $ }}`
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
  Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector

  Usage:
    `{{ include "common.labels.matchLabels" $ }}`
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* source: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_names.tpl */}}
{{/*
  Expand the name of the chart.

  Usage:
    `{{ include "common.names.name" $ }}`
*/}}
{{- define "common.names.name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create chart name and version as used by the chart label.

  Usage:
    `{{ include "common.names.chart" $ }}`
*/}}
{{- define "common.names.chart" -}}
    {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.

  Usage:
    `{{ include "common.names.fullname" $ }}`
*/}}
{{- define "common.names.fullname" -}}
    {{- if .Values.fullnameOverride -}}
        {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- $name := default .Chart.Name .Values.nameOverride -}}
        {{- if contains $name .Release.Name -}}
            {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
        {{- else -}}
            {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
  Allow the release namespace to be overridden for multi-namespace deployments in combined charts.

  Usage:
    `{{ include "common.names.namespace" $ }}`
*/}}
{{- define "common.names.namespace" -}}
    {{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create a fully qualified app name adding the installation's namespace.

  Usage:
    `{{ include "common.names.fullname.namespace" $ }}`
*/}}
{{- define "common.names.fullname.namespace" -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
  Renders a value that contains template.

  Usage:
    `{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}`
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

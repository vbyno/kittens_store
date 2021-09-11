{{- define "kittens-helm.app" -}}
{{- default .Release.Name | trunc 59 | trimSuffix "-" }}-app
{{- end }}

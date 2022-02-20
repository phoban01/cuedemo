package monitoring

#Prometheus: {
	input: #Config & {
		meta: name: *"prometheus" | string
	}
	out: {
		ns: #Namespace & {_config:   input}
		hr: #HelmRelease & {_config: input}
	}
}

#Config: {
	meta: X={
		name:      string
		namespace: *"monitoring-system" | string
		annotations: {...}
		labels: {...}
		labels: app: *X.name | string
	}
}

#Namespace: {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name: _config.meta.namespace
		annotations: {...}
		labels: {...}
	}
}

#HelmRelease: {
	_config:    #Config
	apiVersion: "helm.toolkit.fluxcd.io/v2beta1"
	kind:       "HelmRelease"
	metadata:   _config.meta
	spec: {
		interval: "5m"
		chart: {
			spec: {
				version: "23.2.0"
				chart:   "kube-prometheus-stack"
				sourceRef: {
					kind: "HelmRepository"
					name: "prometheus-community"
				}
				interval: "1m"
			}
		}
		install: crds: "Create"
		upgrade: crds: "CreateReplace"
		values: {
			alertmanager: enabled: "false"
			grafana: {
				sidecar: {
					dashboards: searchNamespace: "ALL"
				}
			}
			prometheus: {
				prometheusSpec: {
					podMonitorSelector: {
						matchLabels: "app.kubernetes.io/part-of": "flux"
					}
				}
			}
		}
	}
}

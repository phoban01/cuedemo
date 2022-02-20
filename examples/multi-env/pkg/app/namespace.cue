package app

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: name: _config.meta.namespace
}

package main

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// We'll define KRM to ensure all of our resources comply with Kubernetes Resource Model
#KRM: {
	metav1.#TypeMeta
	metadata:          metav1.#ObjectMeta
	["spec" | "data"]: runtime.#Object
}

#KRM: {
	apiVersion: string
	kind:       string
	metadata: name:      string
	metadata: namespace: string
}

package main

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
	podinfo "github.com/phoban01/cuedemos/examples/podinfo/app"
)

_hpa: *null | string @tag(_,short=hpa)

resources: (podinfo.#App & {
	input: {
		meta: name: "podinfo"
		image: "ghcr.io/stefanprodan/podinfo"
		tag:   "6.0.3"
		hpa: enabled: _hpa == "hpa"
	}
}).out

out: [ for x in resources {x}]

// resources will hold the resources we want to deploy, ensuring they are all KRMs
resources: [ID=_]: #KRM

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

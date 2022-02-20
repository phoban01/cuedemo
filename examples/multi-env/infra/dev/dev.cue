package platform

import (
	"github.com/phoban01/cuedemo/examples/multi-env/pkg/app"
	"github.com/phoban01/cuedemo/examples/multi-env/pkg/monitoring"
)

resources: (app.#App & {
	input: {
		meta: name:      "podinfo"
		meta: namespace: _env
		image: "ghcr.io/stefanprodan/podinfo"
		tag:   "6.0.3"
	}
}).out

resources: (monitoring.#Prometheus & {}).out

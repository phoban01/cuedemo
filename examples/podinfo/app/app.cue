package app

#Config: {
	meta: {
		name:      string
		namespace: *"default" | string
		labels: app: *meta.name | string
	}
	image:    string
	tag:      string
	port:     *9898 | int
	replicas: *1 | int
	hpa: {
		enabled:     bool
		cpu:         *75 | int
		memory:      *"500Mi" | string
		minReplicas: *1 | int
		maxReplicas: *4 | int
	}
}

#App: {
	input: #Config
	out: {
		sa:      #ServiceAccount & {_config: input}
		deploy:  #Deployment & {_config:     input, _serviceAccount: sa.metadata.name}
		service: #Service & {_config:        input}
	}
	if input.hpa.enabled == true {
		out: hpa: #HorizontalPodAutoscaler & {_config: input}
	}
}

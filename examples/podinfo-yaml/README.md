# Deploying a Kubernetes Application

This example demonstrates how we can configure a simple application on Kubernetes using CUE.

The `resources` expression holds our kubernetes resources. The `out` expression contains a `yaml` encoded stream of Kubernetes manifests.

List the Kubernetes generated resources with the `ls` command:
```bash
cue ls
```

Generate the Kubernetes manifests using the `oyaml` command:
```bash
cue oyaml
```

We can use see what resources will be created using the `dry-run` command:
```bash
cue dry-run
```

We can use the `hpa` flag to enable the `HorizontalPodAutoscaler`:
```bash
cue -t hpa dry-run
```


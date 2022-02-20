package main

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
)

version:      "v0.2.0"
manifest_url: "https://github.com/phoban01/cue-flux-controller/releases/download/\(version)"
flux_path:    "./examples/podinfo-yaml/cluster/"

command: bootstrap: {
	owner: exec.Run & {
		cmd:    "gh repo view --json owner --jq .owner.login"
		stdout: string
	}
	repo: exec.Run & {
		cmd:    "gh repo view --json name --jq .name"
		stdout: string
	}
	flux: exec.Run & {
		cmd: "flux bootstrap github --owner \(owner.stdout) --repository \(repo.stdout) --path \(flux_path)"
	}
}

command: install: {
	install_path: "./cluster/cue-controller"
	mkdir:        file.Mkdir & {
		path:          install_path
		createParents: true
	}
	install_crds: exec.Run & {
		$after: mkdir
		cmd: [ "curl", "-sL", "-o", "\(install_path)/crds.yaml", "\(manifest_url)/cue-controller.crds.yaml"]
	}
	install_controller: {
		deploy: exec.Run & {
			$after: install_crds
			cmd: [ "curl", "-sL", "-o", "\(install_path)/deploy.yaml", "\(manifest_url)/cue-controller.deployment.yaml"]
		}
		rbac: exec.Run & {
			$after: install_crds
			cmd: [ "curl", "-sL", "-o", "\(install_path)/rbac.yaml", "\(manifest_url)/cue-controller.rbac.yaml"]
		}
	}
	msg: cli.Print & {
		$after: install_controller
		text:   "Installed cue-controller \(version) into \(install_path).\nYou can now commit & push the changes to your repo. Flux will reconcile the updated manifests."
	}
}

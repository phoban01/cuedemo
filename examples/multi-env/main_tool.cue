package platform

import (
	"tool/cli"
	"tool/exec"
	"encoding/yaml"
	"text/tabwriter"
	"tool/file"
)

version:      "v0.2.1"
manifest_url: "https://github.com/phoban01/cue-flux-controller/releases/download/\(version)"
flux_path:    "./examples/multi-env/cluster/"

command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"KIND \tNAMESPACE \tNAME",
			for x in out {
				if x.kind == "Namespace" {
					"\(x.kind)  \t  \t\(x.metadata.name)"
				}
				if x.kind != "Namespace" {
					"\(x.kind)  \t\(x.metadata.namespace) \t\(x.metadata.name)"
				}
			},
		])
	}
}

command: oyaml: {
	task: print: cli.Print & {
		text: yaml.MarshalStream(out)
	}
}

command: "dry-run": {
	task: apply: exec.Run & {
		cmd:   "kubectl apply --dry-run=server -f -"
		stdin: yaml.MarshalStream(out)
	}
}

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

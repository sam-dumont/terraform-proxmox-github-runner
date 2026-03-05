# terraform-proxmox-github-runner

Terraform module to deploy self-hosted GitHub Actions runners as Proxmox VMs, using cloud-init.

Each `terraform apply` creates a fresh Ubuntu VM on Proxmox, injects a cloud-init script that installs Docker and registers the VM as an organization-level GitHub Actions runner. The runner token is fetched automatically via the GitHub provider, and the VM gets a unique name via `random_pet` (so you can run multiple runners side by side).

I built this for my homelab running Proxmox on a dedicated server. The original used SOPS-encrypted credentials: this version takes everything as input variables instead.

## How it works

```
terraform apply
      │
      ├─ 1. Fetch runner registration token from GitHub API
      ├─ 2. Render cloud-init template with token + config
      ├─ 3. SCP cloud-init to Proxmox host (/var/lib/vz/snippets/)
      └─ 4. Clone VM template, attach cloud-init, boot
              │
              └─ VM boots ──> cloud-init runs ──> installs Docker
                                                ──> downloads runner
                                                ──> registers with GitHub org
                                                ──> starts as systemd service
```

When the runner token changes (because it expired), `random_pet` generates a new name and Terraform recreates the VM from scratch: you always get a clean runner.

## Usage

```hcl
provider "proxmox" {
  pm_api_url          = "https://proxmox.example.com:8006/api2/json"
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
}

provider "github" {
  owner = "my-org"
  token = var.github_pat
}

module "github_runner" {
  source  = "sam-dumont/github-runner/proxmox"
  version = "~> 1.0"

  proxmox_host     = "proxmox.example.com"
  proxmox_node     = "pve"
  proxmox_template = "ubuntu2410"

  github_org = "my-org"

  domain         = "example.com"
  vm_ip          = "10.0.1.50/24"
  vm_gateway     = "10.0.1.1"
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
```

## Prerequisites

- A Proxmox host with an Ubuntu cloud-init template (the default expects `ubuntu2410`)
- SSH access from the machine running Terraform to the Proxmox host (for transferring the cloud-init snippet)
- A GitHub PAT with `admin:org` scope (needed to generate runner registration tokens)
- A network bridge (`vmbr2` by default) on the Proxmox host

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| [proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest) (telmate/proxmox) | >= 3.0 |
| [github](https://registry.terraform.io/providers/integrations/github/latest) (integrations/github) | >= 6.0 |
| random | >= 3.0 |
| local | >= 2.0 |
| null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| proxmox | >= 3.0 |
| github | >= 6.0 |
| random | >= 3.0 |
| local | >= 2.0 |
| null | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| `proxmox_vm_qemu.github_runner` | resource |
| `random_pet.server` | resource |
| `local_sensitive_file.cloud_init` | resource |
| `null_resource.cloud_init` | resource |
| `github_actions_organization_registration_token.runner` | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `proxmox_host` | Proxmox host FQDN or IP | `string` | n/a | **yes** |
| `proxmox_node` | Proxmox node name to deploy the VM on | `string` | `"proxmox"` | no |
| `proxmox_template` | Name of the Proxmox VM template to clone | `string` | `"ubuntu2410"` | no |
| `github_org` | GitHub organization name for the runner | `string` | n/a | **yes** |
| `domain` | Base domain for the runner VM FQDN | `string` | `"example.com"` | no |
| `vm_ip` | Static IP for the runner VM in CIDR notation | `string` | `"10.20.254.10/24"` | no |
| `vm_gateway` | Gateway IP for the runner VM network | `string` | `"10.20.254.1"` | no |
| `vm_cores` | Number of CPU cores for the runner VM | `number` | `2` | no |
| `vm_memory` | Memory in MB for the runner VM | `number` | `4096` | no |
| `vm_disk_size` | Disk size for the runner VM | `string` | `"32G"` | no |
| `ssh_public_key` | SSH public key for cloud-init | `string` | n/a | **yes** |
| `ssh_private_key_path` | Path to SSH private key for provisioning | `string` | `"~/.ssh/id_rsa"` | no |
| `runner_labels` | Comma-separated labels for the GitHub Actions runner | `string` | `"self-hosted,x64,docker"` | no |
| `runner_version` | GitHub Actions runner version | `string` | `"2.321.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `runner_vm_name` | Name of the Proxmox VM running the GitHub Actions runner |
| `runner_vm_ip` | Static IP address assigned to the runner VM |
| `runner_unique_id` | Random pet name identifying this runner instance |

## Limitations

- Creates one runner VM per apply. For multiple runners, call the module multiple times or use `count`/`for_each`.
- No built-in monitoring or health checks on the runner process.
- Does not create the Proxmox VM template: you need to prepare that yourself (Packer works well for this).

## License

MIT

variable "proxmox_host" {
  type        = string
  description = "Proxmox host FQDN or IP"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name to deploy the VM on"
  default     = "proxmox"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID (e.g. terraform@pve!mytoken)"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}

variable "proxmox_template" {
  type        = string
  description = "Name of the Proxmox VM template to clone"
  default     = "ubuntu2410"
}

variable "github_org" {
  type        = string
  description = "GitHub organization name for the runner"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT with admin:org scope for runner registration"
  sensitive   = true
}

variable "domain" {
  type        = string
  description = "Base domain for the runner VM FQDN"
  default     = "example.com"
}

variable "vm_ip" {
  type        = string
  description = "Static IP for the runner VM in CIDR notation"
  default     = "10.20.254.10/24"
}

variable "vm_gateway" {
  type        = string
  description = "Gateway IP for the runner VM network"
  default     = "10.20.254.1"
}

variable "vm_cores" {
  type        = number
  description = "Number of CPU cores for the runner VM"
  default     = 2
}

variable "vm_memory" {
  type        = number
  description = "Memory in MB for the runner VM"
  default     = 4096
}

variable "vm_disk_size" {
  type        = string
  description = "Disk size for the runner VM"
  default     = "32G"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for cloud-init"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key for provisioning (transferring cloud-init to Proxmox host)"
  default     = "~/.ssh/id_rsa"
}

variable "runner_labels" {
  type        = string
  description = "Comma-separated labels for the GitHub Actions runner"
  default     = "self-hosted,x64,docker"
}

variable "runner_version" {
  type        = string
  description = "GitHub Actions runner version"
  default     = "2.321.0"
}

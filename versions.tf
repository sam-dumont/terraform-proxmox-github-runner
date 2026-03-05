terraform {
  required_version = ">= 1.3"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 3.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

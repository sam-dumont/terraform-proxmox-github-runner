provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}

# Configure your own backend:
# backend "s3" {
#   encrypt        = true
#   bucket         = "your-terraform-state-bucket"
#   region         = "us-east-1"
#   dynamodb_table = "your-terraform-lock-table"
#   key            = "github-runner-proxmox.tfstate"
# }

resource "local_sensitive_file" "cloud_init" {
  content = templatefile("${path.module}/templates/cloud-init.yaml", {
    token          = data.github_actions_organization_registration_token.runner.token
    unique_id      = random_pet.server.id
    domain         = var.domain
    ssh_public_key = var.ssh_public_key
    github_org     = var.github_org
    runner_labels  = var.runner_labels
    runner_version = var.runner_version
  })
  filename = "${path.module}/files/cloud-init.cfg"
}

# Transfer the cloud-init config to the Proxmox host
resource "null_resource" "cloud_init" {
  triggers = {
    sha256 = local_sensitive_file.cloud_init.content_base64sha256
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = var.proxmox_host
  }

  provisioner "file" {
    source      = local_sensitive_file.cloud_init.filename
    destination = "/var/lib/vz/snippets/cloud-init-github-actions.yml"
  }
}

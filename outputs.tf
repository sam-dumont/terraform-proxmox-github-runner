output "runner_vm_name" {
  description = "Name of the Proxmox VM running the GitHub Actions runner"
  value       = proxmox_vm_qemu.github_runner.name
}

output "runner_vm_ip" {
  description = "Static IP address assigned to the runner VM"
  value       = var.vm_ip
}

output "runner_unique_id" {
  description = "Random pet name used to uniquely identify this runner instance"
  value       = random_pet.server.id
}

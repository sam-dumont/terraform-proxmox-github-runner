resource "proxmox_vm_qemu" "github_runner" {
  name       = "github-runner-${random_pet.server.id}"
  desc       = "Deploying a GitHub runner"
  depends_on = [null_resource.cloud_init]

  target_node = var.proxmox_node

  clone   = var.proxmox_template
  agent   = 1
  os_type = "cloud-init"
  cores   = var.vm_cores
  sockets = 1
  vcpus   = 0
  cpu_type = "host"
  memory  = var.vm_memory
  scsihw  = "virtio-scsi-single"

  vga {
    type = "std"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size     = var.vm_disk_size
          storage  = "local"
          discard  = true
          iothread = true
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr2"
    tag    = 0
  }

  boot      = "order=virtio0"
  ipconfig0 = "ip=${var.vm_ip},gw=${var.vm_gateway},ip6=dhcp"
  skip_ipv6 = false

  lifecycle {
    ignore_changes = [
      ciuser,
      sshkeys,
      network
    ]
  }
  cicustom = "user=local:snippets/cloud-init-github-actions.yml"
}

resource "random_pet" "server" {
  keepers = {
    token = sha256(data.github_actions_organization_registration_token.runner.token)
  }
}

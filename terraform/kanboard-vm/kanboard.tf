resource "proxmox_virtual_environment_vm" "kanboard-vm" {
  name      = "kanboard-vm"
  node_name = "homelab"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 2048
  }
  clone {
    vm_id = 9000
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 10
  }

  agent {
    enabled = true
    timeout = "600s"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.kanboard_ip}/24"
        gateway = var.network_gateway
      }
    }

    user_account {
      keys     = [file(var.ssh_public_key_path)]
      username = "admin"
    }
    user_data_file_id = proxmox_virtual_environment_file.kanboard_user_data.id
  }
}


resource "proxmox_virtual_environment_file" "kanboard_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab"

  source_raw {
    file_name = "user-data-kanboard.yaml"
    data = templatefile("${path.module}/cloud-init/user-data-kanboard.sh.tpl", {
      ssh_public_key_path = file(var.ssh_public_key_path)
    })
  }
}
resource "proxmox_virtual_environment_vm" "this" {
  vm_id     = var.vm_id
  name      = var.name
  node_name = var.node_name

  cpu {
    cores = var.cpu
  }

  memory {
    dedicated = var.memory
  }

  clone {
    vm_id = var.vm_template_id
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
  }

  agent {
    enabled = true
    timeout = "600s"
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.vm_ip}/24"
        gateway = var.network_gateway
      }
    }

    user_account {
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
      username = var.username
    }
    user_data_file_id = proxmox_virtual_environment_file.runner_user_data.id
  }
}

resource "proxmox_virtual_environment_file" "runner_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    file_name = "user-data-runner.yaml"
    data = templatefile("${path.module}/cloud-init/user-data-runner.sh.tpl", {
      ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
    })
  }
}

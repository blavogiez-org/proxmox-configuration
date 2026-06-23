resource "proxmox_virtual_environment_vm" "this" {
  vm_id     = var.vm_id
  name      = var.name
  node_name = var.node_name
  cpu {
    cores = var.cpu
    type  = "host"
  }

  memory {
    dedicated = var.memory
    floating  = 512
  }

  clone {
    vm_id = var.vm_template_id
    datastore_id = var.datastore_id
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    iothread     = true
    discard      = "on"
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
    datastore_id = var.datastore_id

    user_account {
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
      username = var.username
    }
    user_data_file_id = proxmox_virtual_environment_file.boostrap_user_data.id
  }
}

resource "proxmox_virtual_environment_file" "boostrap_user_data" {
  content_type = "snippets"
  datastore_id = "local" # encrypted-zfs ne peut pas supporter autre chose que des vm
  node_name    = var.node_name

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data = templatefile(var.user_data_template_path, {
      ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path))),
      hostname       = var.hostname
    })
  }
}

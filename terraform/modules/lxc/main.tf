locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "proxmox_virtual_environment_container" "this" {
  tags = var.tags
  vm_id        = var.lxc_id
  node_name    = var.node_name
  started      = true
  unprivileged = var.unprivileged

  initialization {
    hostname = var.name

    ip_config {
      ipv4 {
        address = "${var.lxc_ip}/24"
        gateway = var.network_gateway
      }
    }

    user_account {
      keys = [local.ssh_public_key]
    }
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  cpu {
    cores = var.cpu
  }

  memory {
    dedicated = var.memory
    swap      = 512
  }

  disk {
    datastore_id = var.target_datastore_id
    size         = var.disk_size
  }

  features {
    nesting = var.nesting
  }

  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
      initialization[0].ip_config,
      network_interface[0].mac_address,
      ipv4,
      ipv6,
    ]
  }
}

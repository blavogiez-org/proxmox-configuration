locals {
  cloud_init_enabled   = var.cloud_init_template_id != null
  cloud_init_seed_path = "/mnt/pve/cloud-init-seeds/${var.name}"
  ssh_public_key       = trimspace(file(pathexpand(var.ssh_public_key_path)))

  cloud_init_template_vars = {
    hostname       = var.name
    username       = var.username
    ssh_public_key = local.ssh_public_key
  }

  cloud_init_default_user_data = <<-EOT
    #cloud-config
    hostname: ${var.name}
    users:
      - default
      - name: ${var.username}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${local.ssh_public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
    EOT

  cloud_init_user_data = var.cloud_init_user_data_file == null ? local.cloud_init_default_user_data : templatefile(
    "${path.root}/cloud-init/${var.cloud_init_user_data_file}",
    local.cloud_init_template_vars
  )
}

resource "local_file" "cloud_init_user_data" {
  count = local.cloud_init_enabled ? 1 : 0

  filename             = "${local.cloud_init_seed_path}/user-data"
  content              = local.cloud_init_user_data
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "local_file" "cloud_init_meta_data" {
  count = local.cloud_init_enabled ? 1 : 0

  filename = "${local.cloud_init_seed_path}/meta-data"
  content  = "instance-id: ct-${var.name}-${var.lxc_id}\nlocal-hostname: ${var.name}\n"

  file_permission      = "0644"
  directory_permission = "0755"
}

resource "proxmox_virtual_environment_container" "this" {
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

    dynamic "user_account" {
      for_each = local.cloud_init_enabled ? [] : [1]

      content {
        keys = [local.ssh_public_key]
      }
    }
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  dynamic "clone" {
    for_each = local.cloud_init_enabled ? [var.cloud_init_template_id] : []

    content {
      vm_id        = clone.value
      datastore_id = var.datastore_id
      full         = true
    }
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
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  features {
    nesting = var.nesting
  }

  dynamic "mount_point" {
    for_each = local.cloud_init_enabled ? [local.cloud_init_seed_path] : []

    content {
      volume    = mount_point.value
      path      = "/var/lib/cloud/seed/nocloud"
      read_only = true
    }
  }

  depends_on = [
    local_file.cloud_init_user_data,
    local_file.cloud_init_meta_data,
  ]
}

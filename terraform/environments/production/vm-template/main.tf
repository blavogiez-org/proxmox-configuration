resource "proxmox_download_file" "debian13" {
  node_name    = var.node_name
  datastore_id = "local"
  content_type = "import"

  # l'url n'est pas forcément stable, les qcow2 sont un peu rares pour les mirrors
  url       = "https://laotzu.ftp.acc.umu.se/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name = "debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "debian13" {
  name      = "debian13-template"
  node_name = var.node_name
  vm_id     = 9030

  started = true

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_download_file.debian13.id
    interface    = "scsi0"
    discard      = "on"
  }

  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  serial_device {}
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  node_name    = var.node_name
  datastore_id = "local"
  content_type = "snippets"

  source_file {
    path      = "${path.module}/cloud-init.yml"
    file_name = "cloud-init.yml"
  }
}

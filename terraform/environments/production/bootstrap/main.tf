resource "proxmox_sdn_zone_simple" "zone_1" {
  id  = "zone1"
  mtu = 1500
}

# pour infra
module "prvvnet1" {
  source         = "../../../modules/sdn-network"
  zone_id        = proxmox_sdn_zone_simple.zone_1.id
  vnet_id        = "prvvnet1"
  subnet_cidr    = "192.168.10.0/24"
  subnet_gateway = "192.168.10.1"
}

# pour services publics
module "pubvnet1" {
  source         = "../../../modules/sdn-network"
  zone_id        = proxmox_sdn_zone_simple.zone_1.id
  vnet_id        = "pubvnet1"
  subnet_cidr    = "172.16.10.0/24"
  subnet_gateway = "172.16.10.1"
}

resource "proxmox_download_file" "debian13" {
  node_name    = var.node_name
  datastore_id = "local"
  content_type = "import"

  url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name = "debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "debian13" {
  name      = "debian13-template"
  node_name = var.node_name
  vm_id     = 9000

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
    path      = "${path.root}/../../../../services/template-vm/cloud-init.yml"
    file_name = "cloud-init.yml"
  }
}

# vm dédiée vault
# https://github.com/openbao/openbao
# https://hub.docker.com/r/openbao/openbao
module "vault" {
  source = "../../../modules/vm"

  hostname            = "vault"
  name                = "vault"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 115
  vm_template_id      = 9000
  vm_ip               = "192.168.10.15"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = "encrypted-zfs"

  cpu       = 1
  memory    = 1024
  disk_size = 15

  bridge                  = "prvvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/vault/cloud-init.yml", {
    hostname         = "vault"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}
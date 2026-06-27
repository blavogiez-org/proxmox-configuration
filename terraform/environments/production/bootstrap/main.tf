resource "proxmox_sdn_zone_simple" "zone_1" {
  id  = "zone1"
  mtu = 1500
}

# pour infra
module "prvvnet1" {
  source         = "../../modules/sdn-network"
  zone_id        = proxmox_sdn_zone_simple.zone_1.id
  vnet_id        = "prvvnet1"
  subnet_cidr    = "192.168.10.0/24"
  subnet_gateway = "192.168.10.1"
}

# pour services publics
module "pubvnet1" {
  source         = "../../modules/sdn-network"
  zone_id        = proxmox_sdn_zone_simple.zone_1.id
  vnet_id        = "pubvnet1"
  subnet_cidr    = "172.16.10.0/24"
  subnet_gateway = "172.16.10.1"
}

# vm dédiée vault
# https://github.com/openbao/openbao
# https://hub.docker.com/r/openbao/openbao
module "vault" {
  source = "../../modules/vm"

  hostname            = "vault"
  name                = "vault"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 115
  vm_template_id      = 9000
  vm_ip               = "192.168.10.15"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id        = "encrypted-zfs"

  cpu       = 1
  memory    = 1024
  disk_size = 15

  bridge                  = "prvvnet1"
  user_data_template_path = "${path.root}/../../../services/vault/cloud-init.yml"
}
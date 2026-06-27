# idée de todo : déduire que c'est prvvnet1 ou pubvnet1 selon l'ip voulue
# repris de https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/sdn_vnet
# les SDN proxmox exposent après leur créatione un bridge exploitable (meme nom que le vnet) avec le SNAT activé par défaut (sortie possible)
resource "proxmox_sdn_zone_simple" "zone_1" {
  id = "zone1"
  mtu = 1500
}

# pour infra
module "prvvnet1" {
  source = "../../modules/sdn-network"
  zone_id = proxmox_sdn_zone_simple.zone_1.id
  vnet_id = "prvvnet1"
  subnet_cidr = "192.168.10.0/24"
  subnet_gateway = "192.168.10.1"
}

# pour services publics
module "pubvnet1" {
  source = "../../modules/sdn-network"
  zone_id = proxmox_sdn_zone_simple.zone_1.id
  vnet_id = "pubvnet1"
  subnet_cidr = "172.16.10.0/24"
  subnet_gateway = "172.16.10.1"
}

module "minimal-backup" {
  source  = "../../modules/backup"
  storage = var.storage
}

# déploiement runner dispo en playbook
module "gh-runner" {
  source = "../../modules/vm"

  hostname            = "gh-runner"
  name                = "gh-runner"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 111
  vm_template_id      = 9000
  vm_ip               = "192.168.10.11"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 2
  memory    = 2048
  disk_size = 10

  bridge = "prvvnet1"
  user_data_template_path = "${path.root}/../../../services/base-vm/cloud-init.yml"
}

# (wireguard se fait sur l'hôte proxmox pour fluidifier les accès réseau)

# https://caddyserver.com/docs/install
# https://github.com/caddyserver/caddy
module "caddy" {
  source = "../../modules/lxc"

  name                = "caddy"
  node_name           = "pve1"
  lxc_id              = 113
  lxc_ip              = "192.168.10.13"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 1
  memory    = 512
  disk_size = 10

  bridge = "prvvnet1"
}

# cf dossier monitoring
module "monitoring" {
  source = "../../modules/vm"

  hostname            = "monitoring"
  name                = "monitoring"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 114
  vm_template_id      = 9000
  vm_ip               = "192.168.10.14"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 1
  memory    = 1024
  disk_size = 25

  bridge = "prvvnet1"
  user_data_template_path = "${path.root}/../../../services/monitoring/cloud-init.yml"
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
  datastore_id = "encrypted-zfs"

  cpu       = 1
  memory    = 1024
  disk_size = 15

  bridge = "prvvnet1"
  user_data_template_path = "${path.root}/../../../services/vault/cloud-init.yml"
}

# https://komo.do/docs/setup
module "komodo" {
  source = "../../modules/vm"

  hostname            = "komodo"
  name                = "komodo"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 211
  vm_template_id      = 9000
  vm_ip               = "172.16.10.11"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 3
  memory    = 4096
  disk_size = 50

  bridge = "pubvnet1"
  user_data_template_path = "${path.root}/../../../services/komodo/cloud-init.yml"
}

module "cloudflared" {
  source = "../../modules/lxc"

  name                = "cloudflared"
  node_name           = "pve1"
  lxc_id              = 212
  lxc_ip              = "172.16.10.12"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 1
  memory    = 256
  disk_size = 8

  bridge = "pubvnet1"
}

# https://docs.goauthentik.io/install-config/install/docker-compose/
module "authentik" {
  source = "../../modules/vm"
  hostname            = "authentik"
  name                = "authentik"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 116
  vm_template_id      = 9000
  vm_ip               = "192.168.10.16"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  datastore_id = "encrypted-zfs"

  cpu       = 1
  memory    = 2048
  disk_size = 10

  bridge = "prvvnet1"
  user_data_template_path = "${path.root}/../../../services/authentik/cloud-init.yml"
}



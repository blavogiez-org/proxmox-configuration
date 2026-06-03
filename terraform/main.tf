module "vlan1" {
  source = "./modules/vlan"

  name      = "vmbr1"
  node_name = "homelab"
  address   = "192.168.10.1/24"
  comment   = "POUR INFRA"
}

module "vlan2" {
  source = "./modules/vlan"

  name      = "vmbr2"
  node_name = "homelab"
  address   = "172.16.10.1/24"
  comment   = "POUR SERVICES EXPOSES A L EXTERIEUR"
}

module "minimal-backup" {
  source = "./modules/backup"
  storage = var.storage
}

module "gh-runner" {
  source = "./modules/vm"

  name                = "gh-runner"
  username            = "admin"
  node_name           = "homelab"
  vm_id               = 111
  vm_template_id      = 9000
  vm_ip               = "192.168.10.11"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path

  cpu       = 2
  memory    = 4096
  disk_size = 10

  bridge = module.vlan1.bridge_name
}

# https://wg-easy.github.io/wg-easy/latest/examples/tutorials/basic-installation/
# https://github.com/wg-easy/wg-easy
module "wireguard" {
  source = "./modules/lxc"

  name                = "wireguard"
  node_name           = "homelab"
  lxc_id              = 112
  lxc_ip              = "192.168.10.12"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path

  cpu       = 1
  memory    = 1024
  disk_size = 10

  bridge = module.vlan1.bridge_name
}

# https://caddyserver.com/docs/install
# https://github.com/caddyserver/caddy
module "caddy" {
  source = "./modules/lxc"

  name                = "caddy"
  node_name           = "homelab"
  lxc_id              = 113
  lxc_ip              = "192.168.10.13"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path

  cpu       = 3
  memory    = 1024
  disk_size = 10

  bridge = module.vlan1.bridge_name
}




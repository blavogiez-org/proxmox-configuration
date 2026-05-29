module "vlan1" {
  source = "./modules/vlan"

  name      = "vlan1"
  vlan_id   = 1
  interface = var.proxmox_interface
  node_name = "homelab"
  address   = "192.168.10.1/24"
  comment   = "POUR INFRA"
}

module "vlan2" {
  source = "./modules/vlan"

  name      = "vlan2"
  vlan_id   = 2
  interface = var.proxmox_interface
  node_name = "homelab"
  address   = "172.16.10.1/24"
  comment   = "POUR SERVICES EXPOSES A L EXTERIEUR"
}

module "minimal-backup" {
  source = "./modules/backup"
}

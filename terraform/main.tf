module "vmbr1" {
  source = "./modules/vlan"

  vlan_id   = 10
  interface = "eno0"
  node_name = "pve"
  address   = "192.168.10.0/24"
  comment    = "POUR INFRA"
}

module "vmbr2" {
  source = "./modules/vlan"

  vlan_id   = 20
  interface = "eno0"
  node_name = "pve"
  address = "172.16.10.0/24"
  comment    = "POUR SERVICES EXPOSES A L EXTERIEUR"
}
# idée de todo : déduire que c'est prvvnet1 ou pubvnet1 selon l'ip voulue
# repris de https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/sdn_vnet
# les SDN proxmox exposent après leur créatione un bridge exploitable (meme nom que le vnet) avec le SNAT activé par défaut (sortie possible). Ce seront ici prvvnet1 et pubvnet1

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
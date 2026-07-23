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

# firewall
resource "proxmox_virtual_environment_cluster_firewall" "cluster" {
  enabled        = true
  forward_policy = "ACCEPT"
}


# Active le backend nftables sur pve1
resource "proxmox_node_firewall" "pve1" {
  node_name         = var.node_name
  enabled           = true
  nftables          = true
  log_level_forward = "info"
}


resource "proxmox_virtual_environment_firewall_rules" "pve1" {
  node_name = var.node_name

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "172.16.10.12/32"
    dest    = "192.168.10.13/32"
    log     = "info"
    comment = "V cloudflared vers caddy"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "172.16.10.0/24"
    dest    = "192.168.10.14/32"
    dport = "9090"
    proto   = "tcp"
    log     = "info"
    comment = "V pubvnet1 vers monitoring (Prometheus)"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "ACCEPT"
    source  = "172.16.10.0/24"
    dest    = "192.168.10.14/32"
    dport = "3100"
    proto   = "tcp"
    log     = "info"
    comment = "V pubvnet1 vers monitoring (Loki)"
    enabled = true
  }

  rule {
    type    = "forward"
    action  = "DROP"
    source  = "172.16.10.0/24"
    dest    = "192.168.10.0/24"
    log     = "info"
    comment = "X pubvnet1 vers prvvnet1 en général"
    enabled = true
  }

  rule {
    type   = "in"
    action = "ACCEPT"
    source = "192.168.1.0/24"
    dest   = ""
    # dport = destination port
    dport   = "51820"
    proto   = "udp"
    log     = "info"
    comment = "V réseau local vers VPN"
    enabled = true
  }

  rule {
    type   = "in"
    action = "ACCEPT"
    source = "192.168.10.13/32"
    dest   = "192.168.1.100/32"
    # dport = destination port
    dport   = "51821"
    proto   = "tcp"
    log     = "info"
    comment = "V caddy vers UI wireguard (réseau privé, site privé vpn.priv.{{ domain }})"
    enabled = true
  }


  depends_on = [
    proxmox_virtual_environment_cluster_firewall.cluster,
    proxmox_node_firewall.pve1
  ]
}

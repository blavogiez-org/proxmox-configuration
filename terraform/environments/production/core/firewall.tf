
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
    comment = "V pubvnet1 vers monitoring (Prometheus restreint uniquement en write avec reverse proxy Caddy)"
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
    comment = "V pubvnet1 vers monitoring (Loki restreint uniquement en write avec reverse proxy Caddy)"
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

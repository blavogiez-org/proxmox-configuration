resource "proxmox_virtual_environment_network_linux_vlan" "this" {
  node_name = var.node_name

  name      = var.name
  interface = var.interface
  vlan      = var.vlan_id
  address   = var.address

  comment = var.comment
}

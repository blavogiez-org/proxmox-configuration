module "vmtropbien" {
  source = "../../../modules/vm"

  name                = "vmtropbien"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 2500
  vm_template_id      = 9000
  vm_ip               = "192.168.10.180"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 1
  memory    = 1024
  disk_size = 10

  bridge = "prvvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname       = "vmtropbien"
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}
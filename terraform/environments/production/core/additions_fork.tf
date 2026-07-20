
module "nextcloud" {
  source = "../../../modules/vm"
  name                = "nextcloud"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 213
  vm_template_id      = 9000
  vm_ip               = "172.16.10.13"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 1
  memory    = 2048
  disk_size = 500

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "nextcloud"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}


module "vaultwarden" {
  source = "../../../modules/vm"
  name                = "vaultwarden"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 117
  vm_template_id      = 9000
  vm_ip               = "192.168.10.17"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 1
  memory    = 1024
  disk_size = 12

  bridge = "prvvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "vaultwarden"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "ck-x" {
  source = "../../../modules/vm"
  name                = "ck-x"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 291
  vm_template_id      = 9000
  vm_ip               = "172.16.10.91"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 3
  memory    = 8192
  disk_size = 50

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "ck-x"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-arbitrary-control-plane-1" {
  source = "../../../modules/vm"
  name                = "k8s-arbitrary-control-plane-1"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 261
  vm_template_id      = 9000
  vm_ip               = "172.16.10.61"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 4
  memory    = 8192
  disk_size = 20

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "k8s-arbitrary-control-plane-1"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-arbitrary-worker-1" {
  source = "../../../modules/vm"
  name                = "k8s-arbitrary-worker-1"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 262
  vm_template_id      = 9000
  vm_ip               = "172.16.10.62"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 4
  memory    = 8192
  disk_size = 20

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "k8s-arbitrary-worker-1"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-arbitrary-worker-2" {
  source = "../../../modules/vm"
  name                = "k8s-arbitrary-worker-2"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 263
  vm_template_id      = 9000
  vm_ip               = "172.16.10.63"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 4
  memory    = 8192
  disk_size = 20

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname         = "k8s-arbitrary-worker-2"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}
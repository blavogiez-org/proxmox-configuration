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

module "zot" {
  source = "../../../modules/lxc"

  name                = "zot"
  node_name           = var.node_name
  lxc_id              = 119
  lxc_ip              = "192.168.10.19"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 3
  memory    = 5012
  disk_size = 50

  bridge = "prvvnet1"
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

#K8S avec ArgoCD
# installer argocd ici
# : https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/
# : https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

module "k8s-control-plane-1" {
  tags = ["kube-control-plane", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-control-plane-1"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 261
  vm_template_id      = 9000
  vm_ip               = "172.16.10.61"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-control-plane-1"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-control-plane-2" {
  tags = ["kube-control-plane", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-control-plane-2"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 262
  vm_template_id      = 9000
  vm_ip               = "172.16.10.62"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-control-plane-2"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-worker-1" {
  tags = ["kube-worker", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-worker-1"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 263
  vm_template_id      = 9000
  vm_ip               = "172.16.10.63"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-worker-1"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-worker-2" {
  tags = ["kube-worker", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-worker-2"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 264
  vm_template_id      = 9000
  vm_ip               = "172.16.10.64"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-worker-2"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-worker-3" {
  tags = ["kube-worker", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-worker-3"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 265
  vm_template_id      = 9000
  vm_ip               = "172.16.10.65"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-worker-3"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "k8s-control-plane-3" {
  tags = ["kube-control-plane", "temp"]
  source = "../../../modules/vm"
  name                = "k8s-control-plane-3"
  username            = "admin"
  node_name           = "pve1"
  vm_id               = 266
  vm_template_id      = 9000
  vm_ip               = "172.16.10.66"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id = var.storage

  cpu       = 8
  memory    = 16384
  disk_size = 80

  bridge = "pubvnet1"
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/kubernetes-cloud-init.yml", {
    hostname         = "k8s-control-plane-3"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

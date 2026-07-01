# idée de todo : déduire que c'est prvvnet1 ou pubvnet1 selon l'ip voulue
# repris de https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/sdn_vnet
# les SDN proxmox exposent après leur créatione un bridge exploitable (meme nom que le vnet) avec le SNAT activé par défaut (sortie possible)
module "minimal-backup" {
  source  = "../../../modules/backup"
  storage = var.backup_storage
}

# déploiement runner dispo en playbook
module "gh-runner" {
  source = "../../../modules/vm"

  hostname            = "gh-runner"
  name                = "gh-runner"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 111
  vm_template_id      = 9000
  vm_ip               = "192.168.10.11"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 2
  memory    = 2048
  disk_size = 10

  bridge = "prvvnet1"

  # Pas de secrets Vault ici, juste les variables de base
  user_data_raw = templatefile("${path.root}/../../../../services/base-vm/cloud-init.yml", {
    hostname       = "gh-runner"
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

# (wireguard se fait sur l'hôte proxmox pour fluidifier les accès réseau)

# https://caddyserver.com/docs/install
# https://github.com/caddyserver/caddy
module "caddy" {
  source = "../../../modules/lxc"

  name                = "caddy"
  node_name           = var.node_name
  lxc_id              = 113
  lxc_ip              = "192.168.10.13"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 1
  memory    = 512
  disk_size = 10

  bridge = "prvvnet1"
}

# cf dossier monitoring
module "monitoring" {
  source = "../../../modules/vm"

  hostname            = "monitoring"
  name                = "monitoring"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 114
  vm_template_id      = 9000
  vm_ip               = "192.168.10.14"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 1
  memory    = 1024
  disk_size = 25

  bridge = "prvvnet1"

  # Pas de secrets Vault ici non plus
  user_data_raw = templatefile("${path.root}/../../../../services/monitoring/cloud-init.yml", {
    hostname       = "monitoring"
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

# https://komo.do/docs/setup
module "komodo" {
  source = "../../../modules/vm"

  hostname            = "komodo"
  name                = "komodo"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 211
  vm_template_id      = 9000
  vm_ip               = "172.16.10.11"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 3
  memory    = 4096
  disk_size = 50

  bridge = "pubvnet1"

  user_data_raw = templatefile("${path.root}/../../../../services/komodo/cloud-init.yml", {
    hostname       = "komodo"
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

module "cloudflared" {
  source = "../../../modules/lxc"

  name                = "cloudflared"
  node_name           = var.node_name
  lxc_id              = 212
  lxc_ip              = "172.16.10.12"
  network_gateway     = "172.16.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 1
  memory    = 256
  disk_size = 8

  bridge = "pubvnet1"
}

# https://docs.goauthentik.io/install-config/install/docker-compose/
module "authentik" {
  source = "../../../modules/vm"

  hostname            = "authentik"
  name                = "authentik"
  username            = "admin"
  node_name           = var.node_name
  vm_id               = 116
  vm_template_id      = 9000
  vm_ip               = "192.168.10.16"
  network_gateway     = "192.168.10.1"
  ssh_public_key_path = var.ssh_public_key_path
  target_datastore_id        = var.storage

  cpu       = 1
  memory    = 2048
  disk_size = 10

  bridge = "prvvnet1"

  # Injection de la clé secrète et du mot de passe DB pour Authentik
  user_data_raw = templatefile("${path.root}/../../../../services/authentik/cloud-init.yml", {
    hostname         = "authentik"
    ssh_public_key   = trimspace(file(pathexpand(var.ssh_public_key_path)))
    pg_pass          = data.vault_generic_secret.authentik_secrets.data["pg_pass"]
    authentik_secret = data.vault_generic_secret.authentik_secrets.data["secret_key"]
  })
}
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "= 0.107.0"
    }
  }

  backend "http" {
    # les variables terraform ne sont pas possibles ici (pour pas mettre en clair), il faut export en env
    # faire remote-backend-init.sh avant
    address = "https://terraform-backend.priv.blavogiez.fr/client/maintainers/proxmox-gitops/pve1/state"
    lock_address = "https://terraform-backend.priv.blavogiez.fr/client/maintainers/proxmox-gitops/pve1/lock"
    unlock_address = "https://terraform-backend.priv.blavogiez.fr/client/maintainers/proxmox-gitops/pve1/unlock"
    lock_method = "POST"
    unlock_method = "POST"
  }

}

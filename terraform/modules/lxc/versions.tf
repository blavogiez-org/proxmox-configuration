terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }

    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

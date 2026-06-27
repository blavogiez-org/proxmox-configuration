provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ssh {
    username    = var.proxmox_ssh_username
    agent       = false
    private_key = file(pathexpand(var.proxmox_ssh_private_key_path))
  }
}

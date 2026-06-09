variable "proxmox_endpoint" {
  description = "Endpoint API Proxmox, exemple: https://pve.home.arpa:8006/api2/json"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token API Proxmox."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Ignore la verification TLS du certificat Proxmox."
  type        = bool
  default     = true
}


variable "proxmox_ssh_username" {
  description = "Utilisateur SSH sur le node Proxmox. Requis pour uploader les snippets/hook scripts."
  type        = string
  default     = "root"
}

variable "proxmox_ssh_private_key_path" {
  description = "Chemin de la cle privee SSH pour le node Proxmox."
  type        = string
  default     = "~/.ssh/proxmox_terraform"
}

variable "ssh_public_key_path" {
  description = "Chemin de la cle publique SSH a injecter dans la VM."
  type        = string
}

variable "storage" {
  type = string
}

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

variable "proxmox_ssh_agent" {
  description = "Utilise ssh-agent au lieu d'une cle privee explicite."
  type        = bool
  default     = false
}

variable "proxmox_interface" {
  description = "Nom de l'interface réseau de la machine."
  type        = string
  default     = "eno0"
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
  nullable    = true
}
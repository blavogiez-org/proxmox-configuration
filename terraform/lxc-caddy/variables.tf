variable "endpoint" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "caddy_ip" {
  type = string
}

variable "gateway" {
  type = string
}

variable "name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "vm_template_id" {
  type = number
}

variable "vm_ip" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "network_gateway" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "username" {
  type    = string
  default = "debian"
}

variable "cpu" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "bridge" {
  type = string
}

variable "vlan_id" {
  type    = number
  default = null
}

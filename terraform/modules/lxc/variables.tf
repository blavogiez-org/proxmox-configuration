variable "name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "lxc_id" {
  type = number
}

variable "lxc_ip" {
  type = string
}

variable "network_gateway" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
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

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "template_file_id" {
  type    = string
  default = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
}

variable "os_type" {
  type    = string
  default = "debian"
}

variable "bridge" {
  type = string
}

variable "vlan_id" {
  type    = number
  default = null
}

variable "unprivileged" {
  type    = bool
  default = true
}

variable "nesting" {
  type    = bool
  default = true
}

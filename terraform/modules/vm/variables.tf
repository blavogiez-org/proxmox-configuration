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

variable "user_data_template_path" {
  type = string
}

variable "datastore_id" {
  type=string
  default= "local-lvm"
}

variable "hostname" {
  type = string 
  default = "hostname-a-remplacer-alloy-en-a-besoin"
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
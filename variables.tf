variable "project" {
  default = "kawsar-demo"
}

variable "network_name" {
  default = "VM Network"
}

variable "dc_name" {
  description = "VMware datacenter name"
}

variable "datastore_name" {
  default = "datastore1"
}

variable "ubuntu_user" {
}

variable "ubuntu_password" {
}

variable "num_cpus" {
}

variable "memory" {
}

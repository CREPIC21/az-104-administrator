variable "resource_group_name" {
  type        = string
  description = "Defines the name of the resource group"
}

variable "location" {
  type        = string
  description = "Defines the location of the virtual network"
}

variable "virtual_network_name" {
  type        = string
  description = "Defines the name of the virtual network"
}

variable "virtual_network_address_space" {
  type        = string
  description = "Defines the name of the virtual network address space"
}

variable "subnet_names" {
  type        = set(string)
  description = "Defines the name of the virtual network subnet names"
}

variable "bastion_required" {
  type        = bool
  description = "Defines if Bastion Service should be provisioned"
  default     = false
}

variable "network_security_group_names" {
  type        = map(string)
  description = "Defines the names of network security groups"
}

variable "network_security_group_rules" {
  type        = list(any)
  description = "Defines the network security rules"
}

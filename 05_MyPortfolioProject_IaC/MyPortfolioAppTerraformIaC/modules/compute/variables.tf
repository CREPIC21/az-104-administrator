variable "network_interface_name" {
  type        = string
  description = "Defines the network interface name"
}

variable "resource_group_name" {
  type        = string
  description = "Defines the name of the resource group"
}

variable "location" {
  type        = string
  description = "Defines the location of the virtual network"
}

variable "subnet_id" {
  type        = string
  description = "Defines the subnet id"
}

variable "private_ip_address_allocation" {
  type        = string
  description = "Defines the private ip address allocation"
  default     = "Dynamic"
}

variable "public_ip_name" {
  type        = string
  description = "Defines the public ip address"
  default     = "default-ip"
}

variable "public_ip_required" {
  type        = bool
  description = "Defines the public ip address"
  default     = false
}

variable "virtual_machine_name" {
  type        = string
  description = "Defines the virtual machine"
}

variable "admin_username" {
  type        = string
  description = "Defines the admin user name for the virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Defines the admin password for the virtual machine"
}

variable "source_image_reference" {
  type        = map(any)
  description = "Defines the source image reference for the virtual machine"
}

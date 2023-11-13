variable "resource_group_name" {
  type    = string
  default = "staging-grp"
}

variable "location" {
  type    = string
  default = "North Europe"
}

variable "virtual_network" {
  type = map(any)
  default = {
    address_space = "10.0.0.0/16"
  }
}

variable "storage_account_name" {
  type    = string
  default = "danstore836725"
}

variable "DB_VM_ADMIN_USERNAME" {
  type = string
}

variable "DB_VM_ADMIN_PASSWORD" {
  type = string
}

variable "SQL_USERNAME" {
  type = string
}

variable "SQL_PASSWORD" {
  type = string
}

variable "db_virtual_machine_name" {
  type    = string
  default = "db-vm"
}

variable "extension_name" {
  type        = string
  description = "This defines the name of the extension"
}

variable "virtual_machine_id" {
  type        = string
  description = "This defines the id of the virtual machine"
}

variable "extension_type" {
  type        = map(any)
  description = "This defines the extension type"
}

variable "storage_account_name" {
  type        = string
  description = "This defines storage account name"
}

variable "container_name" {
  type        = string
  description = "This defines the container name"
}

variable "SQL_USERNAME" {
  type        = string
  description = "This defines username for SQL Database connection"
}

variable "SQL_PASSWORD" {
  type        = string
  description = "This defines password for SQL Database connection"
}





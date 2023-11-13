variable "storage_account_name" {
  type        = string
  description = "Defines the storage account name"
}

variable "resource_group_name" {
  type        = string
  description = "Defines the name of the resource group"
}

variable "location" {
  type        = string
  description = "Defines the location of the virtual network"
}

variable "container_name" {
  type        = string
  description = "Defines the container name"
}

variable "app_container_name" {
  type        = string
  description = "Defines the container name for the application"
  default     = "default"
}

variable "container_access" {
  type        = string
  description = "Defines the container access level"
  default     = "private"
}

variable "blobs" {
  type        = map(any)
  description = "Defines the blobs to be added"
  default = {
    "" = ""
  }
}

variable "blobs_binary" {
  type        = map(any)
  description = "Defines the binary blobs to be added"
  default = {
    "" = ""
  }
}

variable "storage_account_exists" {
  type        = bool
  description = "Defines if the storage account exists"
  default     = false
}

variable "blobs_enabled" {
  type        = bool
  description = "Defines if the blobs need to be uploaded"
  default     = false
}


variable "blobs_binary_enabled" {
  type        = bool
  description = "Defines if the binary blobs need to be uploaded"
  default     = false
}


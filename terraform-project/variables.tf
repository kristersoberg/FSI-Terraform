variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "9bec7245-9d51-4e0a-8448-c4febc9367b0"
}

variable "location_01" {
  description = "Azure region"
  type        = string
  default     = "Norway East"
}

variable "resource_group_01" {
  description = "Resource group name"
  type        = string
}

variable "virtual_network_01" {
  description = "Virtual Network name"
  type        = string
}

variable "address_space_01" {
  description = "Virtual network address space"
  type        = list(string)
}

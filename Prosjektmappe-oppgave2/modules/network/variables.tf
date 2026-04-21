variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name, used in resource names"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create, each with its own NSG rules"
  type = list(object({
    name = string
    cidr = string
    nsg_rules = list(object({
      name        = string
      priority    = number
      direction   = string
      protocol    = string
      port        = number
      source      = string
      destination = string
    }))
  }))
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
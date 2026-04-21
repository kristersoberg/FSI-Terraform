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

variable "subnet_id" {
  description = "ID of the subnet the load balancer will be placed in"
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "frontend_private_ip" {
  description = "Static private IP address for the load balancer frontend. Must be within the subnet CIDR."
  type        = string
}

variable "backend_ips" {
  description = "List of private IP addresses to register as backends"
  type        = list(string)
}

variable "rules" {
  description = "List of load balancing rules"
  type = list(object({
    name           = string
    frontend_port  = number
    backend_port   = number
    protocol       = string
    probe_protocol = string
    probe_port     = number
  }))
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
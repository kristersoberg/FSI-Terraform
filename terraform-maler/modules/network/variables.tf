variable "resource_group_name" {
  description = "Navn på Azure resource group der nettverket skal opprettes"
  type        = string
}

variable "location" {
  description = "Azure-region (f.eks. 'norwayeast', 'westeurope')"
  type        = string
}

variable "environment" {
  description = "Miljønavn – brukes i ressursnavn (f.eks. 'dev', 'prod')"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR-blokk for hele det virtuelle nettverket"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_prefix" {
  description = "CIDR-blokk for web-subnet (offentlig lag)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_prefix" {
  description = "CIDR-blokk for database-subnet (privat lag)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ssh_source_address" {
  description = "IP-adresse eller CIDR som får SSH-tilgang. Bruk din egen IP i produksjon."
  type        = string
  default     = "*"
}
variable "resource_group_name" {
  description = "Navn på Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure-region"
  type        = string
}

variable "environment" {
  description = "Miljønavn – brukes i ressursnavn"
  type        = string
}

variable "lb_name" {
  description = "Navn på lastbalansereren (f.eks. 'database', 'app')"
  type        = string
  default     = "internal"
}

variable "subnet_id" {
  description = "ID til subnettet lastbalansereren plasseres i. Hentes fra network-modulens output."
  type        = string
}

variable "vnet_id" {
  description = "ID til VNet. Hentes fra network-modulens output."
  type        = string
}

variable "frontend_ip" {
  description = "Fast privat IP-adresse for lastbalansereren (må være innenfor subnet-CIDR)"
  type        = string
  default     = "10.0.2.100"
}

variable "backend_port" {
  description = "Port som lastbalansereren videresender trafikk til (f.eks. 3306 for MySQL)"
  type        = number
  default     = 3306
}

variable "backend_ips" {
  description = "Liste over private IP-adresser til backend-serverne. Hentes fra vm-modulens output."
  type        = list(string)
}

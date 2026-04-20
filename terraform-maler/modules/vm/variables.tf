variable "resource_group_name" {
  description = "Navn på Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure-region"
  type        = string
}

variable "vm_name" {
  description = "Navn på VM-en (f.eks. 'web-vm', 'db-vm-1')"
  type        = string
}

variable "vm_size" {
  description = "Azure VM-størrelse (f.eks. 'Standard_B1s', 'Standard_B2s')"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Brukernavn for administrator-konto"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Passord for administrator-konto"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "ID til subnettet VM-en skal plasseres i. Hentes fra network-modulens output."
  type        = string
}

variable "create_public_ip" {
  description = "Opprett offentlig IP-adresse. Sett til true for web-servere, false for database-servere."
  type        = bool
  default     = false
}

variable "startup_script" {
  description = "Bash-script som kjøres ved første oppstart (cloud-init). Brukes til å installere programvare."
  type        = string
  default     = ""
}

variable "vm_role" {
  description = "Rolle-tag for VM-en (f.eks. 'web', 'database'). Brukes for oversikt i Azure-portalen."
  type        = string
  default     = "general"
}

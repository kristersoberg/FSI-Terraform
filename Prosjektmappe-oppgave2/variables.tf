# -----------------------------------------------
# Sensitive – values go in secrets.tfvars (gitignored)
# -----------------------------------------------

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
  sensitive   = true
}

variable "admin_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "mysql_app_password" {
  description = "Password for the 'webuser' MySQL account used by the Flask app"
  type        = string
  sensitive   = true
}

variable "admin_source_ip" {
  description = "Your public IP address, used to restrict SSH access (e.g. '1.2.3.4/32')"
  type        = string
  sensitive   = true
}

# -----------------------------------------------
# Infrastructure – values go in terraform.tfvars
# -----------------------------------------------

variable "location" {
  description = "Azure region to deploy resources into"
  type        = string
  default     = "norwayeast"
}

variable "environment" {
  description = "Short environment label, used in resource names (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-webdb-dev"
}

variable "vnet_address_space" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidr" {
  description = "CIDR block for the web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "database_subnet_cidr" {
  description = "CIDR block for the database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "lb_frontend_ip" {
  description = "Static private IP for the internal load balancer frontend (must be within database_subnet_cidr)"
  type        = string
  default     = "10.0.2.10"
}

variable "web_vm_private_ip" {
  description = "Static private IP for the web VM (must be within web_subnet_cidr)"
  type        = string
  default     = "10.0.1.10"
}

variable "db_1_private_ip" {
  description = "Static private IP for database VM 1 (must be within database_subnet_cidr)"
  type        = string
  default     = "10.0.2.11"
}

variable "db_2_private_ip" {
  description = "Static private IP for database VM 2 (must be within database_subnet_cidr)"
  type        = string
  default     = "10.0.2.12"
}

variable "admin_username" {
  description = "Administrator username on all VMs"
  type        = string
  default     = "azureuser"
}

variable "web_vm_size" {
  description = "Azure VM size for the web VM"
  type        = string
  default     = "Standard_B1s"
}

variable "db_vm_size" {
  description = "Azure VM size for the database VMs"
  type        = string
  default     = "Standard_B1s"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "webdb"
    environment = "dev"
    managed_by  = "terraform"
  }
}

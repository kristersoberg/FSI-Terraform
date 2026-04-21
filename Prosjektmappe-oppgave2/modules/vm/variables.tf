variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet the VM will be placed in"
  type        = string
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "image_publisher" {
  description = "OS image publisher"
  type        = string
}

variable "image_offer" {
  description = "OS image offer"
  type        = string
}

variable "image_sku" {
  description = "OS image SKU"
  type        = string
}

variable "auth_type" {
  description = "Authentication method: 'password' or 'ssh'"
  type        = string
  default     = "ssh"

  validation {
    condition     = contains(["password", "ssh"], var.auth_type)
    error_message = "auth_type must be 'password' or 'ssh'."
  }
}

variable "admin_password" {
  description = "Required when auth_type = 'password'"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_public_key" {
  description = "Required when auth_type = 'ssh'"
  type        = string
  sensitive   = true
  default     = null
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "private_ip_address" {
  description = "Static private IP address. Leave null to use dynamic allocation."
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Attach a public IP to the VM"
  type        = bool
  default     = false
}

variable "os_disk_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "os_disk_type must be 'Standard_LRS', 'StandardSSD_LRS' or 'Premium_LRS'."
  }
}

variable "startup_script" {
  description = "Bash script to run on first boot"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "data_disks" {
  description = "List of additional data disks to attach"
  type = list(object({
    size_gb = number
    type    = string
  }))
  default = []
}
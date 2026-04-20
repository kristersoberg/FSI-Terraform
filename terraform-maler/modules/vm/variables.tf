# =============================================
# REQUIRED
# =============================================

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region (e.g. 'norwayeast', 'westeurope')"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine (e.g. 'web-vm', 'db-vm-1')"
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
  description = "OS image publisher (e.g. 'Canonical', 'Debian', 'MicrosoftWindowsServer')"
  type        = string
}

variable "image_offer" {
  description = "OS image offer (e.g. '0001-com-ubuntu-server-focal', 'debian-11')"
  type        = string
}

variable "image_sku" {
  description = "OS image SKU (e.g. '20_04-lts', '11-gen2')"
  type        = string
}

# =============================================
# AUTHENTICATION
# =============================================

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
  description = "Admin password. Required when auth_type = 'password'."
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_public_key" {
  description = "Public SSH key contents. Required when auth_type = 'ssh'."
  type        = string
  sensitive   = true
  default     = null
}

# =============================================
# OPTIONAL
# =============================================

variable "vm_size" {
  description = "Azure VM size (e.g. 'Standard_B1s', 'Standard_B2s', 'Standard_B4ms')"
  type        = string
  default     = "Standard_B1s"
}

variable "create_public_ip" {
  description = "Attach a public IP address. Set to true for web servers, false for internal servers."
  type        = bool
  default     = false
}

variable "os_disk_type" {
  description = "OS disk storage type: 'Standard_LRS', 'StandardSSD_LRS' or 'Premium_LRS'"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "os_disk_type must be 'Standard_LRS', 'StandardSSD_LRS' or 'Premium_LRS'."
  }
}

variable "startup_script" {
  description = "Bash script to run on first boot (cloud-init)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Key/value pairs for tagging Azure resources"
  type        = map(string)
  default     = {}
}

# =============================================
# DATA DISKS
# =============================================

variable "data_disks" {
  description = <<-EOT
    List of additional data disks to create and attach to the VM.
    Example:
      data_disks = [
        { size_gb = 32, type = "Standard_LRS" },
        { size_gb = 64, type = "Premium_LRS"  }
      ]
  EOT
  type = list(object({
    size_gb = number
    type    = string
  }))
  default = []
}
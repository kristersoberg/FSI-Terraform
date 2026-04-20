variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "storage_type" {
  description = "Where to store the private key: 'local' or 'keyvault'"
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "keyvault"], var.storage_type)
    error_message = "storage_type must be 'local' or 'keyvault'."
  }
}

variable "local_key_path" {
  description = "Directory to save the private key when storage_type = 'local'"
  type        = string
  default     = "~/.ssh"
}

variable "keyvault_id" {
  description = "Resource ID of the Key Vault to store the private key in. Required when storage_type = 'keyvault'."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
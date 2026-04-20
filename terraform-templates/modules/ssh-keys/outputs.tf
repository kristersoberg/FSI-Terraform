output "public_key" {
  description = "Public key contents — pass directly to the vm module as ssh_public_key"
  value       = tls_private_key.this.public_key_openssh
}

output "private_key_path" {
  description = "Path to the private key file on disk (null if storage_type = 'keyvault')"
  value       = var.storage_type == "local" ? "${var.local_key_path}/${var.key_name}.pem" : null
}

output "private_key_secret_id" {
  description = "Key Vault secret ID of the private key (null if storage_type = 'local')"
  value       = var.storage_type == "keyvault" ? azurerm_key_vault_secret.private_key[0].id : null
}
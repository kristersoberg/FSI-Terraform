resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  count           = var.storage_type == "local" ? 1 : 0
  content         = tls_private_key.this.private_key_pem
  filename        = "${var.local_key_path}/${var.key_name}.pem"
  file_permission = "0600"
}

resource "azurerm_key_vault_secret" "private_key" {
  count        = var.storage_type == "keyvault" ? 1 : 0
  name         = "${var.key_name}-private-key"
  value        = tls_private_key.this.private_key_pem
  key_vault_id = var.keyvault_id

  tags = var.tags
}

locals {
  validate_keyvault = (
    var.storage_type == "keyvault" && var.keyvault_id == null
    ? tobool("keyvault_id must be set when storage_type is 'keyvault'")
    : true
  )
}
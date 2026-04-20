resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

resource "azurerm_management_lock" "this" {
  count      = var.lock ? 1 : 0
  name       = "lock-${var.name}"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Protected by Terraform. Set lock = false to remove."
}
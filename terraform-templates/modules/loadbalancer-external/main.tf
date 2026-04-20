resource "azurerm_public_ip" "this" {
  name                = "pip-lb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = "lb-external-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  count                   = length(var.backend_ips)
  name                    = "backend-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = var.vnet_id
  ip_address              = var.backend_ips[count.index]
}

resource "azurerm_lb_probe" "this" {
  for_each = { for rule in var.rules : rule.name => rule }

  name            = "probe-${each.value.name}"
  loadbalancer_id = azurerm_lb.this.id
  protocol        = each.value.probe_protocol
  port            = each.value.probe_port
}

resource "azurerm_lb_rule" "this" {
  for_each = { for rule in var.rules : rule.name => rule }

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.this[each.key].id
  idle_timeout_in_minutes        = 4
}
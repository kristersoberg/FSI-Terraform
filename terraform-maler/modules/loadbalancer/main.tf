resource "azurerm_lb" "this" {
  name                = "lb-${var.lb_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "lb-frontend"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.frontend_ip
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id     = azurerm_lb.this.id
  name                = "health-probe"
  protocol            = "Tcp"
  port                = var.backend_port
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.backend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.this.id
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}

resource "azurerm_lb_backend_address_pool_address" "backends" {
  for_each = { for idx, ip in var.backend_ips : "backend-${idx}" => ip }

  name                    = each.key
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = var.vnet_id
  ip_address              = each.value
}

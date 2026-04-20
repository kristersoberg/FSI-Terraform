output "lb_id" {
  description = "ID til lastbalansereren"
  value       = azurerm_lb.this.id
}

output "lb_ip" {
  description = "Privat IP-adresse til lastbalansereren – web-VM-en bruker denne for å nå databasene"
  value       = var.frontend_ip
}

output "backend_pool_id" {
  description = "ID til backend-poolen"
  value       = azurerm_lb_backend_address_pool.this.id
}

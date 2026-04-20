output "lb_id" {
  description = "Resource ID of the load balancer"
  value       = azurerm_lb.this.id
}

output "frontend_ip" {
  description = "Public IP address of the load balancer frontend"
  value       = azurerm_public_ip.this.ip_address
}

output "public_ip_id" {
  description = "Resource ID of the public IP"
  value       = azurerm_public_ip.this.id
}

output "backend_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.this.id
}
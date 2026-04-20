output "lb_id" {
  description = "Resource ID of the load balancer"
  value       = azurerm_lb.this.id
}

output "frontend_ip" {
  description = "Private IP address of the load balancer frontend"
  value       = var.frontend_private_ip
}

output "backend_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.this.id
}
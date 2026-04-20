output "vnet_id" {
  description = "ID til det virtuelle nettverket"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Navn på det virtuelle nettverket"
  value       = azurerm_virtual_network.main.name
}

output "web_subnet_id" {
  description = "ID til web-subnet – brukes som input til vm-modulen"
  value       = azurerm_subnet.web.id
}

output "db_subnet_id" {
  description = "ID til database-subnet – brukes som input til vm- og loadbalancer-modulen"
  value       = azurerm_subnet.db.id
}
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "nsg_ids" {
  description = "Map of subnet name to NSG ID"
  value       = { for name, nsg in azurerm_network_security_group.this : name => nsg.id }
}
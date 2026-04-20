output "vm_id" {
  description = "ID til den opprettede VM-en"
  value       = azurerm_linux_virtual_machine.this.id
}

output "private_ip" {
  description = "Privat IP-adresse – brukes som input til loadbalancer-modulen"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "Offentlig IP-adresse (null hvis create_public_ip = false)"
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "nic_id" {
  description = "ID til nettverkskortet"
  value       = azurerm_network_interface.this.id
}

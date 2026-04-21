output "vm_id" {
  description = "Resource ID of the VM"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip" {
  description = "Private IP address"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "Public IP address (null if create_public_ip = false)"
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "nic_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.this.id
}

output "data_disk_ids" {
  description = "List of attached data disk IDs"
  value       = [for disk in azurerm_managed_disk.this : disk.id]
}
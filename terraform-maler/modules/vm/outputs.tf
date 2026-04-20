output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip" {
  description = "Private IP address — pass this to the loadbalancer module as part of backend_ips"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "Public IP address. Returns null if create_public_ip is false."
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.this.id
}

output "data_disk_ids" {
  description = "List of IDs for any attached data disks"
  value       = [for disk in azurerm_managed_disk.this : disk.id]
}
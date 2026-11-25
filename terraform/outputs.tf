output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Grupo de recursos PM04"
}

output "app_public_ip" {
  value       = azurerm_public_ip.app.ip_address
  description = "IP pública de la app (HTTPS pendiente de configurar por Ansible)"
}

output "app_private_ip" {
  value = azurerm_network_interface.app.private_ip_address
}

output "db_private_ip" {
  value       = azurerm_network_interface.db.private_ip_address
  description = "MongoDB: IP privada, sin IP pública propia"
}

output "app_vm_name" {
  value = azurerm_linux_virtual_machine.app.name
}

output "db_vm_name" {
  value = azurerm_linux_virtual_machine.db.name
}

output "mongo_disk_id" {
  value = azurerm_managed_disk.mongo_data.id
}

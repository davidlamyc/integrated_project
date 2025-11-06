output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.hub_spoke_rg.name
}

output "hub_vnet_id" {
  description = "ID of the hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_address_space" {
  description = "Address space of the hub VNet"
  value       = azurerm_virtual_network.hub.address_space
}

output "frontend_spoke_vnet_id" {
  description = "ID of the frontend spoke VNet"
  value       = azurerm_virtual_network.frontend_spoke.id
}

output "core_spoke_vnet_id" {
  description = "ID of the core spoke VNet"
  value       = azurerm_virtual_network.core_spoke.id
}

output "backend_spoke_vnet_id" {
  description = "ID of the backend spoke VNet"
  value       = azurerm_virtual_network.backend_spoke.id
}

# output "azure_firewall_private_ip" {
#   description = "Private IP address of Azure Firewall"
#   value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# output "azure_firewall_public_ip" {
#   description = "Public IP address of Azure Firewall"
#   value       = azurerm_public_ip.firewall.ip_address
# }

output "bastion_public_ip" {
  description = "Public IP address of Azure Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_dns_name" {
  description = "DNS name of Azure Bastion"
  value       = azurerm_bastion_host.hub.dns_name
}
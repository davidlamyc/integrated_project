# Peering: Hub to Frontend Spoke
resource "azurerm_virtual_network_peering" "hub_to_frontend" {
  name                      = "peer-hub-to-frontend"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.frontend_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

# Peering: Frontend Spoke to Hub
resource "azurerm_virtual_network_peering" "frontend_to_hub" {
  name                      = "peer-frontend-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.frontend_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# Peering: Hub to Core Spoke
resource "azurerm_virtual_network_peering" "hub_to_core" {
  name                      = "peer-hub-to-core"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.core_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

# Peering: Core Spoke to Hub
resource "azurerm_virtual_network_peering" "core_to_hub" {
  name                      = "peer-core-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.core_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# Peering: Hub to Backend Spoke
resource "azurerm_virtual_network_peering" "hub_to_backend" {
  name                      = "peer-hub-to-backend"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.backend_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

# Peering: Backend Spoke to Hub
resource "azurerm_virtual_network_peering" "backend_to_hub" {
  name                      = "peer-backend-to-hub"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.backend_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# Frontend Spoke Virtual Network
resource "azurerm_virtual_network" "frontend_spoke" {
  name                = var.frontend_spoke_vnet_name
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = var.frontend_spoke_address_space

  tags = {
    Environment = "Frontend"
    Purpose     = "Frontend Applications"
  }
}

# Frontend spoke subnets - provision multiple for future applications
resource "azurerm_subnet" "frontend_app1" {
  name                 = "snet-frontend-app1"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.frontend_spoke.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "frontend_app2" {
  name                 = "snet-frontend-app2"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.frontend_spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "frontend_app3" {
  name                 = "snet-frontend-app3"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.frontend_spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "frontend_private_endpoints" {
  name                 = "snet-frontend-private-endpoints"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.frontend_spoke.name
  address_prefixes     = ["10.1.10.0/24"]
}

# Core Spoke Virtual Network
resource "azurerm_virtual_network" "core_spoke" {
  name                = var.core_spoke_vnet_name
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = var.core_spoke_address_space

  tags = {
    Environment = "Core"
    Purpose     = "Core Services"
  }
}

# Core spoke subnets - provision multiple for future applications
resource "azurerm_subnet" "core_app1" {
  name                 = "snet-core-app1"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.core_spoke.name
  address_prefixes     = ["10.2.0.0/24"]

  # Add this delegation block
  delegation {
    name = "app-service-delegation"
    
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "core_app2" {
  name                 = "snet-core-app2"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.core_spoke.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "core_app3" {
  name                 = "snet-core-app3"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.core_spoke.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "core_private_endpoints" {
  name                 = "snet-core-private-endpoints"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.core_spoke.name
  address_prefixes     = ["10.2.10.0/24"]
}

# Backend Spoke Virtual Network
resource "azurerm_virtual_network" "backend_spoke" {
  name                = var.backend_spoke_vnet_name
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = var.backend_spoke_address_space

  tags = {
    Environment = "Backend"
    Purpose     = "Backend Services"
  }
}

# Backend spoke subnets - provision multiple for future applications
resource "azurerm_subnet" "backend_app1" {
  name                 = "snet-backend-app1"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.backend_spoke.name
  address_prefixes     = ["10.3.0.0/24"]
}

resource "azurerm_subnet" "backend_app2" {
  name                 = "snet-backend-app2"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.backend_spoke.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_subnet" "backend_app3" {
  name                 = "snet-backend-app3"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.backend_spoke.name
  address_prefixes     = ["10.3.2.0/24"]
}

resource "azurerm_subnet" "backend_private_endpoints" {
  name                 = "snet-backend-private-endpoints"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.backend_spoke.name
  address_prefixes     = ["10.3.10.0/24"]
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data source to reference the existing resource group from Layer 1
data "azurerm_resource_group" "hub_spoke_rg" {
  name = var.foundation_resource_group_name
}

# Data source to reference the frontend spoke VNet from Layer 1
data "azurerm_virtual_network" "frontend_spoke" {
  name                = var.frontend_spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the core spoke VNet from Layer 1
data "azurerm_virtual_network" "core_spoke" {
  name                = var.core_spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the backend spoke VNet from Layer 1
data "azurerm_virtual_network" "backend_spoke" {
  name                = var.backend_spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the frontend app1 subnet from Layer 1
data "azurerm_subnet" "frontend_app1" {
  name                 = "snet-frontend-app1"
  virtual_network_name = data.azurerm_virtual_network.frontend_spoke.name
  resource_group_name  = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the core app1 subnet from Layer 1
data "azurerm_subnet" "core_app1" {
  name                 = "snet-core-app1"
  virtual_network_name = data.azurerm_virtual_network.core_spoke.name
  resource_group_name  = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the backend app1 subnet from Layer 1
data "azurerm_subnet" "backend_app1" {
  name                 = "snet-backend-app1"
  virtual_network_name = data.azurerm_virtual_network.backend_spoke.name
  resource_group_name  = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference backend private endpoints from Layer 1
data "azurerm_subnet" "backend_private_endpoints" {
  name                 = "snet-backend-private-endpoints"
  virtual_network_name = data.azurerm_virtual_network.backend_spoke.name
  resource_group_name  = data.azurerm_resource_group.hub_spoke_rg.name
}

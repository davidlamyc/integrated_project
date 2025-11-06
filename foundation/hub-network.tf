# Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = var.hub_vnet_address_space

  tags = {
    Environment = "Hub"
    Purpose     = "Network Hub"
  }
}

# # Azure Firewall Subnet (must be named AzureFirewallSubnet)
# resource "azurerm_subnet" "firewall" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
#   virtual_network_name = azurerm_virtual_network.hub.name
#   address_prefixes     = ["10.0.1.0/26"]
# }

# Azure Bastion Subnet (must be named AzureBastionSubnet)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]
}

# # Public IP for Azure Firewall
# resource "azurerm_public_ip" "firewall" {
#   name                = "pip-firewall"
#   location            = azurerm_resource_group.hub_spoke_rg.location
#   resource_group_name = azurerm_resource_group.hub_spoke_rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = {
#     Environment = "Hub"
#   }
# }

# # Azure Firewall
# resource "azurerm_firewall" "hub" {
#   name                = "afw-hub"
#   location            = azurerm_resource_group.hub_spoke_rg.location
#   resource_group_name = azurerm_resource_group.hub_spoke_rg.name
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.firewall.id
#     public_ip_address_id = azurerm_public_ip.firewall.id
#   }

#   tags = {
#     Environment = "Hub"
#   }
# }

# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Hub"
  }
}

# Azure Bastion Host
resource "azurerm_bastion_host" "hub" {
  name                = "bastion-hub"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  sku                 = "Standard"
  tunneling_enabled   = true
  shareable_link_enabled = false

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = {
    Environment = "Hub"
  }
}

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

# Data source for existing subnet
# data "azurerm_subnet" "existing" {
#   name                 = "your-existing-subnet-name"
#   virtual_network_name = "your-vnet-name"
#   resource_group_name  = "your-vnet-rg-name"
# }
data "azurerm_virtual_network" "core_spoke" {
  name                = var.core_spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.hub_spoke_rg.name
}

# Data source to reference the core app2 subnet from Layer 1
data "azurerm_subnet" "core_app2" {
  name                 = "snet-core-app2"
  virtual_network_name = data.azurerm_virtual_network.core_spoke.name
  resource_group_name  = data.azurerm_resource_group.hub_spoke_rg.name
}

data "azuread_user" "admin_user" {
  user_principal_name = "davidlam.yc_gmail.com#EXT#@davidlamycgmail.onmicrosoft.com"
}

data "azurerm_client_config" "current" {}

# Data Lake Storage Gen2 (Required for Synapse)
resource "azurerm_storage_account" "synapse_storage" {
  name                     = "coresynapsestore"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true  # Required for Data Lake Gen2
  
#   # Disable public access if you want fully private
#   public_network_access_enabled = false

  # Ensure shared access key is enabled (default)
  shared_access_key_enabled = true
  
  # Keep public access enabled during initial setup
  public_network_access_enabled = true
}

# resource "azurerm_role_assignment" "terraform_storage_access" {
#   scope                = azurerm_storage_account.synapse_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# # Small delay to allow RBAC propagation
# resource "time_sleep" "wait_for_rbac" {
#   depends_on      = [azurerm_role_assignment.terraform_storage_access]
#   create_duration = "60s"
# }

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_fs" {
  name               = "core-synapsefilesystem"
  storage_account_id = azurerm_storage_account.synapse_storage.id

#   depends_on = [time_sleep.wait_for_rbac]
}

# Random suffix for unique names
# resource "random_string" "suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

# Synapse Workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "core-synapse-workspace"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_fs.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "YourP@ssw0rd123!"  # Use Azure Key Vault in production
  
  # Managed VNet integration
  managed_virtual_network_enabled = true
  
  # Disable public network access for fully private setup
  public_network_access_enabled = true
  
  # Identity for managed access
  identity {
    type = "SystemAssigned"
  }
  
  tags = {
    environment = "dev"
  }
}

# # Allow your current IP
# resource "azurerm_synapse_firewall_rule" "allow_my_ip" {
#   name                 = "AllowMyIP"
#   synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
#   start_ip_address     = "14.100.1.17"
#   end_ip_address       = "14.100.1.17"
# }

# # Allow Azure services (required for Azure services to access)
# resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
#   name                 = "AllowAllWindowsAzureIps"
#   synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
#   start_ip_address     = "0.0.0.0"
#   end_ip_address       = "0.0.0.0"
# }

resource "azurerm_synapse_firewall_rule" "allow_all" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

# Grant Synapse access to storage
# resource "azurerm_role_assignment" "synapse_storage_blob_contributor" {
#   scope                = azurerm_storage_account.synapse_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
# }

resource "azurerm_synapse_role_assignment" "admin" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Administrator"
  principal_id         = data.azuread_user.admin_user.object_id
  
  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

resource "azurerm_synapse_role_assignment" "contributor" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Contributor"
  principal_id         = data.azuread_user.admin_user.object_id
  
  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

resource "azurerm_synapse_role_assignment" "artifact_publisher" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Artifact Publisher"
  principal_id         = data.azuread_user.admin_user.object_id
  
  depends_on = [
    azurerm_synapse_workspace.synapse_workspace
  ]
}

# Grant storage access to your user
# resource "azurerm_role_assignment" "user_storage_blob_contributor" {
#   scope                = azurerm_storage_account.synapse_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = data.azuread_user.admin_user.object_id
# }

# Also grant to Synapse workspace identity (if not already done)
# resource "azurerm_role_assignment" "synapse_storage_blob_contributor" {
#   scope                = azurerm_storage_account.synapse_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
# }

# Private DNS Zones (create these if they don't exist)
resource "azurerm_private_dns_zone" "synapse_sql" {
  name                = "privatelink.sql.azuresynapse.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "synapse_dev" {
  name                = "privatelink.dev.azuresynapse.net"
  resource_group_name = var.resource_group_name
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "synapse_sql_link" {
  name                  = "synapse-sql-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_sql.name
  virtual_network_id    = data.azurerm_virtual_network.core_spoke.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_dev_link" {
  name                  = "synapse-dev-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_dev.name
  virtual_network_id    = data.azurerm_virtual_network.core_spoke.id
}

# Private Endpoint for Synapse SQL (Serverless)
resource "azurerm_private_endpoint" "synapse_sql" {
  name                = "synapse-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.core_app2.id

  private_service_connection {
    name                           = "synapse-sql-psc"
    private_connection_resource_id = azurerm_synapse_workspace.synapse_workspace.id
    subresource_names              = ["Sql"]  # For serverless SQL pool
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "synapse-sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.synapse_sql.id]
  }
}

# Private Endpoint for Synapse Dev (Studio/APIs)
resource "azurerm_private_endpoint" "synapse_dev" {
  name                = "synapse-dev-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.core_app2.id

  private_service_connection {
    name                           = "synapse-dev-psc"
    private_connection_resource_id = azurerm_synapse_workspace.synapse_workspace.id
    subresource_names              = ["Dev"]  # For Synapse Studio
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "synapse-dev-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.synapse_dev.id]
  }
}

# Optional: Private Endpoint for Storage (DFS)
resource "azurerm_private_dns_zone" "storage_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dfs_link" {
  name                  = "storage-dfs-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dfs.name
  virtual_network_id    = data.azurerm_virtual_network.core_spoke.id
}

resource "azurerm_private_endpoint" "storage_dfs" {
  name                = "synapse-storage-dfs-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.core_app2.id

  private_service_connection {
    name                           = "storage-dfs-psc"
    private_connection_resource_id = azurerm_storage_account.synapse_storage.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dfs-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dfs.id]
  }
}

# Outputs
output "synapse_workspace_name" {
  value = azurerm_synapse_workspace.synapse_workspace.name
}

output "synapse_serverless_endpoint" {
  value = "${azurerm_synapse_workspace.synapse_workspace.name}-ondemand.sql.azuresynapse.net"
}

output "synapse_studio_url" {
  value = "https://web.azuresynapse.net?workspace=%2Fsubscriptions%2F${data.azurerm_client_config.current.subscription_id}%2FresourceGroups%2F${var.resource_group_name}%2Fproviders%2FMicrosoft.Synapse%2Fworkspaces%2F${azurerm_synapse_workspace.synapse_workspace.name}"
}

# data "azurerm_client_config" "current" {}
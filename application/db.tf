# SQL Server
resource "azurerm_mssql_server" "backend-mssql-server" {
  name                         = "backend-mssql-server"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "ChangeMe123!@#"  # Use Key Vault in production!
  
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false  # Disable public access

#   azuread_administrator {
#     login_username = "davidlam.yc@gmail.com"
#     object_id      = "f5d17da8-4e25-4b7d-9378-31962ed74b4d"
#   }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
    tier        = "backend"
  }
}

# SQL Database
resource "azurerm_mssql_database" "backend-mssql-db" {
  name           = "backend-mssql-db"
  server_id      = azurerm_mssql_server.backend-mssql-server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
#   max_size_gb    = 32
  sku_name       = "S1"  # Basic, S0-S12, P1-P15, GP_S_Gen5_2, etc.
  zone_redundant = false

  tags = {
    environment = "dev"
  }
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "backend-private-dns-zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

# Link Private DNS Zone to Backend VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql-backend-link" {
  name                  = "sql-backend-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.backend-private-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.backend_spoke.id
  registration_enabled  = false
}

# Link Private DNS Zone to Core VNet (so App Service can resolve)
resource "azurerm_private_dns_zone_virtual_network_link" "app-core-link" {
  name                  = "app-core-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.backend-private-dns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.core_spoke.id
  registration_enabled  = false
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql-private-endpoint" {
  name                = "pe-sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.backend_private_endpoints.id

  private_service_connection {
    name                           = "pe-connection-sql"
    private_connection_resource_id = azurerm_mssql_server.backend-mssql-server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.backend-private-dns-zone.id]
  }

  tags = {
    environment = "dev"
  }
}
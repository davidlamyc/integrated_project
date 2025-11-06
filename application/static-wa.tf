# Static Web App (for React frontend)
resource "azurerm_static_site" "frontend" {
  name                = "stapp-frontend"
  location            = "eastasia"  # Static Web Apps have limited regions
  resource_group_name = var.resource_group_name
  sku_tier            = "Standard"  # Free or Standard
  sku_size            = "Standard"

  tags = {
    environment = "dev"
    tier        = "frontend"
  }
}

# Output the deployment token for CI/CD
output "static_web_app_api_key" {
  value     = azurerm_static_site.frontend.api_key
  sensitive = true
}

output "static_web_app_url" {
  value = azurerm_static_site.frontend.default_host_name
}
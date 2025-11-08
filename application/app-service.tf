# Create App Service Plan (Linux)
resource "azurerm_service_plan" "core-asp" {
  name                = "core-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "P1v3"  # Choose appropriate SKU (B1, S1, P1v3, etc.)
}

# Create Linux App Service
resource "azurerm_linux_web_app" "core-awa" {
  name                = "core-awa"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.core-asp.id

  site_config {
    always_on = true
    
    # For FastAPI with Python
    application_stack {
      python_version = "3.11"  # Or your required version
    }
    
    # Optional: Configure CORS if needed
    cors {
      allowed_origins = ["*"]
    }
  }

  # Application settings
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  # Enable VNet Integration
  virtual_network_subnet_id = data.azurerm_subnet.core_app1.id

  https_only = true
}

# Output the API URL
output "api_url" {
  value = "https://${azurerm_linux_web_app.core-awa.default_hostname}"
}
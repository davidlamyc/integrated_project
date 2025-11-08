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

    app_command_line = "python -m uvicorn main:app --host 0.0.0.0 --port 8000"
    
    # Optional: Configure CORS if needed
    cors {
      allowed_origins = ["*"]
    }
  }

  # Application settings
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "ENABLE_ORYX_BUILD"              = "true"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    
    application_logs {
      file_system_level = "Verbose"  # Options: Off, Error, Warning, Information, Verbose
    }
    
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }


  # Enable VNet Integration
  virtual_network_subnet_id = data.azurerm_subnet.core_app1.id

  https_only = true
}

# Output the API URL
output "api_url" {
  value = "https://${azurerm_linux_web_app.core-awa.default_hostname}"
}
# # Firewall Policy
# resource "azurerm_firewall_policy" "hub" {
#   name                = "afwp-hub"
#   resource_group_name = azurerm_resource_group.hub_spoke_rg.name
#   location            = azurerm_resource_group.hub_spoke_rg.location
#   sku                 = "Standard"

#   threat_intelligence_mode = "Alert"

#   tags = {
#     Environment = "Hub"
#   }
# }

# # Network Rule Collection - Allow spoke-to-spoke and outbound traffic
# resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
#   name               = "NetworkRuleCollectionGroup"
#   firewall_policy_id = azurerm_firewall_policy.hub.id
#   priority           = 100

#   network_rule_collection {
#     name     = "AllowSpokeToSpoke"
#     priority = 100
#     action   = "Allow"

#     rule {
#       name                  = "AllowFrontendToCore"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["10.2.0.0/16"]
#       destination_ports     = ["*"]
#     }

#     rule {
#       name                  = "AllowCoreToFrontend"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.2.0.0/16"]
#       destination_addresses = ["10.1.0.0/16"]
#       destination_ports     = ["*"]
#     }

#     rule {
#       name                  = "AllowFrontendToBackend"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.1.0.0/16"]
#       destination_addresses = ["10.3.0.0/16"]
#       destination_ports     = ["*"]
#     }

#     rule {
#       name                  = "AllowBackendToFrontend"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.3.0.0/16"]
#       destination_addresses = ["10.1.0.0/16"]
#       destination_ports     = ["*"]
#     }

#     rule {
#       name                  = "AllowCoreToBackend"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.2.0.0/16"]
#       destination_addresses = ["10.3.0.0/16"]
#       destination_ports     = ["*"]
#     }

#     rule {
#       name                  = "AllowBackendToCore"
#       protocols             = ["TCP", "UDP", "ICMP"]
#       source_addresses      = ["10.3.0.0/16"]
#       destination_addresses = ["10.2.0.0/16"]
#       destination_ports     = ["*"]
#     }
#   }

#   network_rule_collection {
#     name     = "AllowOutbound"
#     priority = 200
#     action   = "Allow"

#     rule {
#       name              = "AllowDNS"
#       protocols         = ["UDP"]
#       source_addresses  = ["10.0.0.0/8"]
#       destination_addresses = ["*"]
#       destination_ports = ["53"]
#     }

#     rule {
#       name              = "AllowHTTP"
#       protocols         = ["TCP"]
#       source_addresses  = ["10.0.0.0/8"]
#       destination_addresses = ["*"]
#       destination_ports = ["80"]
#     }

#     rule {
#       name              = "AllowHTTPS"
#       protocols         = ["TCP"]
#       source_addresses  = ["10.0.0.0/8"]
#       destination_addresses = ["*"]
#       destination_ports = ["443"]
#     }

#     rule {
#       name              = "AllowNTP"
#       protocols         = ["UDP"]
#       source_addresses  = ["10.0.0.0/8"]
#       destination_addresses = ["*"]
#       destination_ports = ["123"]
#     }
#   }
# }

# # Application Rule Collection - Allow web access
# resource "azurerm_firewall_policy_rule_collection_group" "application_rules" {
#   name               = "ApplicationRuleCollectionGroup"
#   firewall_policy_id = azurerm_firewall_policy.hub.id
#   priority           = 200

#   application_rule_collection {
#     name     = "AllowWeb"
#     priority = 100
#     action   = "Allow"

#     rule {
#       name = "AllowWindows Update"
#       source_addresses = ["10.0.0.0/8"]
      
#       protocols {
#         type = "Https"
#         port = 443
#       }

#       protocols {
#         type = "Http"
#         port = 80
#       }

#       destination_fqdns = [
#         "*.windowsupdate.microsoft.com",
#         "*.update.microsoft.com",
#         "*.windowsupdate.com",
#         "download.microsoft.com",
#         "*.download.windowsupdate.com",
#         "wustat.windows.com",
#         "ntservicepack.microsoft.com",
#       ]
#     }

#     rule {
#       name = "AllowAzureServices"
#       source_addresses = ["10.0.0.0/8"]
      
#       protocols {
#         type = "Https"
#         port = 443
#       }

#       destination_fqdns = [
#         "*.azure.com",
#         "*.microsoft.com",
#         "*.msftconnecttest.com",
#       ]
#     }
#   }
# }
# # Route Table for Frontend Spoke
# resource "azurerm_route_table" "frontend_spoke" {
#   name                          = "rt-frontend-spoke"
#   location                      = azurerm_resource_group.hub_spoke_rg.location
#   resource_group_name           = azurerm_resource_group.hub_spoke_rg.name
#   bgp_route_propagation_enabled = false

#   tags = {
#     Environment = "Frontend"
#   }
# }

# # Route: Frontend to Internet via Firewall
# resource "azurerm_route" "frontend_to_internet" {
#   name                   = "route-to-internet"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.frontend_spoke.name
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Frontend to Core via Firewall
# resource "azurerm_route" "frontend_to_core" {
#   name                   = "route-to-core"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.frontend_spoke.name
#   address_prefix         = "10.2.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Frontend to Backend via Firewall
# resource "azurerm_route" "frontend_to_backend" {
#   name                   = "route-to-backend"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.frontend_spoke.name
#   address_prefix         = "10.3.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Associate route table with Frontend subnets
# resource "azurerm_subnet_route_table_association" "frontend_app1" {
#   subnet_id      = azurerm_subnet.frontend_app1.id
#   route_table_id = azurerm_route_table.frontend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "frontend_app2" {
#   subnet_id      = azurerm_subnet.frontend_app2.id
#   route_table_id = azurerm_route_table.frontend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "frontend_app3" {
#   subnet_id      = azurerm_subnet.frontend_app3.id
#   route_table_id = azurerm_route_table.frontend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "frontend_private_endpoints" {
#   subnet_id      = azurerm_subnet.frontend_private_endpoints.id
#   route_table_id = azurerm_route_table.frontend_spoke.id
# }

# # Route Table for Core Spoke
# resource "azurerm_route_table" "core_spoke" {
#   name                          = "rt-core-spoke"
#   location                      = azurerm_resource_group.hub_spoke_rg.location
#   resource_group_name           = azurerm_resource_group.hub_spoke_rg.name
#   bgp_route_propagation_enabled = false

#   tags = {
#     Environment = "Core"
#   }
# }

# # Route: Core to Internet via Firewall
# resource "azurerm_route" "core_to_internet" {
#   name                   = "route-to-internet"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.core_spoke.name
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Core to Frontend via Firewall
# resource "azurerm_route" "core_to_frontend" {
#   name                   = "route-to-frontend"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.core_spoke.name
#   address_prefix         = "10.1.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Core to Backend via Firewall
# resource "azurerm_route" "core_to_backend" {
#   name                   = "route-to-core-backend"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.core_spoke.name
#   address_prefix         = "10.3.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Associate route table with Core subnets
# resource "azurerm_subnet_route_table_association" "core_app1" {
#   subnet_id      = azurerm_subnet.core_app1.id
#   route_table_id = azurerm_route_table.core_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "core_app2" {
#   subnet_id      = azurerm_subnet.core_app2.id
#   route_table_id = azurerm_route_table.core_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "core_app3" {
#   subnet_id      = azurerm_subnet.core_app3.id
#   route_table_id = azurerm_route_table.core_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "core_private_endpoints" {
#   subnet_id      = azurerm_subnet.core_private_endpoints.id
#   route_table_id = azurerm_route_table.core_spoke.id
# }

# # Route Table for Backend Spoke
# resource "azurerm_route_table" "backend_spoke" {
#   name                          = "rt-backend-spoke"
#   location                      = azurerm_resource_group.hub_spoke_rg.location
#   resource_group_name           = azurerm_resource_group.hub_spoke_rg.name
#   bgp_route_propagation_enabled = false

#   tags = {
#     Environment = "Backend"
#   }
# }

# # Route: Backend to Internet via Firewall
# resource "azurerm_route" "backend_to_internet" {
#   name                   = "route-to-internet"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.backend_spoke.name
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Backend to Frontend via Firewall
# resource "azurerm_route" "backend_to_frontend" {
#   name                   = "route-to-frontend"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.backend_spoke.name
#   address_prefix         = "10.1.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Route: Backend to Core via Firewall
# resource "azurerm_route" "backend_to_core" {
#   name                   = "route-to-backend-core"
#   resource_group_name    = azurerm_resource_group.hub_spoke_rg.name
#   route_table_name       = azurerm_route_table.backend_spoke.name
#   address_prefix         = "10.2.0.0/16"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
# }

# # Associate route table with Backend subnets
# resource "azurerm_subnet_route_table_association" "backend_app1" {
#   subnet_id      = azurerm_subnet.backend_app1.id
#   route_table_id = azurerm_route_table.backend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "backend_app2" {
#   subnet_id      = azurerm_subnet.backend_app2.id
#   route_table_id = azurerm_route_table.backend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "backend_app3" {
#   subnet_id      = azurerm_subnet.backend_app3.id
#   route_table_id = azurerm_route_table.backend_spoke.id
# }

# resource "azurerm_subnet_route_table_association" "backend_private_endpoints" {
#   subnet_id      = azurerm_subnet.backend_private_endpoints.id
#   route_table_id = azurerm_route_table.backend_spoke.id
# }

# Network Interface for Frontend VM
resource "azurerm_network_interface" "frontend_vm" {
  name                = "nic-vm-frontend"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend_app1.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = "Frontend"
  }
}

# Network Security Group for Frontend VM
resource "azurerm_network_security_group" "frontend_vm" {
  name                = "nsg-vm-frontend"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name

  # Allow all inbound traffic
  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # security_rule {
  #   name                       = "AllowICMP"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Icmp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "10.0.0.0/8"
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "AllowRDP"
  #   priority                   = 110
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "3389"
  #   source_address_prefix      = "10.0.0.0/8"
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "AllowSSH"
  #   priority                   = 120
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = "10.0.0.0/8"
  #   destination_address_prefix = "*"
  # }

  tags = {
    Environment = "Frontend"
  }
}

# Associate NSG with Frontend NIC
resource "azurerm_network_interface_security_group_association" "frontend_vm" {
  network_interface_id      = azurerm_network_interface.frontend_vm.id
  network_security_group_id = azurerm_network_security_group.frontend_vm.id
}

# Frontend VM (Windows)
resource "azurerm_windows_virtual_machine" "frontend" {
  name                = "vm-frontend-tst"
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  location            = azurerm_resource_group.hub_spoke_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.frontend_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment = "Frontend"
    Purpose     = "Test VM"
  }
}
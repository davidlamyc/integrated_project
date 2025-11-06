variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hubspoke-network"
}

variable "foundation_resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hubspoke-network"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet"
  type        = string
  default     = "vnet-hub"
}

variable "hub_vnet_address_space" {
  description = "Address space for hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "frontend_spoke_vnet_name" {
  description = "Name of the frontend spoke VNet"
  type        = string
  default     = "vnet-spoke-frontend"
}

variable "frontend_spoke_address_space" {
  description = "Address space for frontend spoke VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "core_spoke_vnet_name" {
  description = "Name of the core spoke VNet"
  type        = string
  default     = "vnet-spoke-core"
}

variable "core_spoke_address_space" {
  description = "Address space for core spoke VNet"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "backend_spoke_vnet_name" {
  description = "Name of the backend spoke VNet"
  type        = string
  default     = "vnet-spoke-backend"
}

variable "backend_spoke_address_space" {
  description = "Address space for backend spoke VNet"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

variable "admin_username" {
  description = "Admin username for test VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for test VMs"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the test VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "allowed_source_ip" {
  description = "Your public IP address for Bastion access"
  type        = string
}

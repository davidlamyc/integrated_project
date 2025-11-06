variable "core_spoke_vnet_name" {
  description = "Name of the core spoke VNet"
  type        = string
  default     = "vnet-spoke-core"
}

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
}
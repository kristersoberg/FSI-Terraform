# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  } 
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "resource_group_1" {
  name     = var.resource_group_01
  location = var.location_01
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "virtual_network_1" {
  name                = var.virtual_network_01
  resource_group_name = azurerm_resource_group.resource_group_1.name
  location            = azurerm_resource_group.resource_group_1.location
  address_space       = var.address_space_01
}
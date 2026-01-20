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
  subscription_id = var.subid
}

#Importerer variabler automatisk fra variables.tf og terraform.tfvars

# Opprett en ressursgruppe
resource "azurerm_resource_group" "resource_group_1" {
  name     = var.ressurs_gruppe_navn
  location = var.lokasjon
}

# Opprett et virtuelt nettverk
resource "azurerm_virtual_network" "vnet_1" {
  name                = var.vnet_navn
  resource_group_name = azurerm_resource_group.resource_group_1.name
  location            = azurerm_resource_group.resource_group_1.location
  address_space       = var.ip_range
}

#Opprette 2 subnett for det virtuelle nettverket
resource "azurerm_subnet" "vnet_1_subnet" {
  count = length(var.subnet_navn)  # Finner antall subnet. 
  name = var.subnet_navn[count.index]  # Henter navn fra subnet_navn-listen
  address_prefixes	 = [var.subnet_ranges[count.index]]  # Henter adresseområdet fra subnet_ranges-listen
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  resource_group_name = azurerm_resource_group.resource_group_1.name
}

# Opprette et NSG, med regler - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group


provider "azurerm" {
  features {}
}

#----------------------------------------------------------------------------------------
# Resourcegroups
#----------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = "rg-network-${var.env}-001"
  location = "westeurope"
}

//----------------------------------------------------------------------------------------
// Existing vnet
//----------------------------------------------------------------------------------------

# data "azurerm_virtual_network" "existing" {
#   for_each = var.bastion

#   name                = each.value.vnet.existing.virtual_network_name
#   resource_group_name = each.value.vnet.existing.resource_group_name
# }

//----------------------------------------------------------------------------------------
// New vnet
//----------------------------------------------------------------------------------------

resource "azurerm_virtual_network" "new" {
  for_each = var.bastion

  name                = "vnet-${each.key}-${each.value.location}"
  address_space       = each.value.vnet.new.cidr
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg.name
}

//----------------------------------------------------------------------------------------
// Subnet
//----------------------------------------------------------------------------------------

resource "azurerm_subnet" "sn" {
  for_each = var.bastion

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.new[each.key].name
  address_prefixes     = each.value.vnet.new.subnet_cidr
}

//----------------------------------------------------------------------------------------
// Public ip
//----------------------------------------------------------------------------------------

resource "azurerm_public_ip" "pip" {
  for_each = var.bastion

  name                = "pip-${each.key}-${each.value.location}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

//----------------------------------------------------------------------------------------
// Bastion
//----------------------------------------------------------------------------------------

resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion

  name                = "bas-${each.key}-${each.value.location}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.sn[each.key].id
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}
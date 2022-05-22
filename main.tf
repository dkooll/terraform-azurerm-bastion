# provider "azurerm" {
#   features {}
# }

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

data "azurerm_virtual_network" "vnet" {
  for_each = var.bastion

  name                = each.value.existing.vnetname
  resource_group_name = each.value.existing.rgname
}

//----------------------------------------------------------------------------------------
// Subnet
//----------------------------------------------------------------------------------------

resource "azurerm_subnet" "sn" {
  for_each = var.bastion

  name                 = "AzureBastionSubnet"
  resource_group_name  = each.value.existing.rgname
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.subnet_address_prefix
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
  copy_paste_enabled  = each.value.enable_copy_paste
  file_copy_enabled   = each.value.enable_file_copy
  tunneling_enabled   = each.value.enable_tunneling

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.sn[each.key].id
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

#----------------------------------------------------------------------------------------
# Nsg's
#----------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  for_each = var.bastion

  name                = "nsg-${each.key}-${each.value.location}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = each.value.location

  dynamic "security_rule" {
    for_each = local.rules

    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      description                  = lookup(security_rule.value, "description", null)
      source_port_range            = lookup(security_rule.value, "sourcePortRange", null)
      source_port_ranges           = lookup(security_rule.value, "sourcePortRanges", null)
      destination_port_range       = lookup(security_rule.value, "destinationPortRange", null)
      destination_port_ranges      = lookup(security_rule.value, "destinationPortRanges", null)
      source_address_prefix        = lookup(security_rule.value, "sourceAddressPrefix", null)
      source_address_prefixes      = lookup(security_rule.value, "sourceAddressPrefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destinationAddressPrefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destinationAddressPrefixes", null)
    }
  }
}

#----------------------------------------------------------------------------------------
# Nsg subnet associations
#----------------------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  for_each = var.bastion

  subnet_id                 = azurerm_subnet.sn[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
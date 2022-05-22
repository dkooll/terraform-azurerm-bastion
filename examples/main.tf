provider "azurerm" {
  features {}
}

module "vnet" {
  source = "github.com/dkooll/terraform-azurerm-vnet"
  vnets = {
    vnet1 = { cidr = ["10.0.0.0/16"], location = "westeurope" }
    vnet2 = { cidr = ["10.0.0.0/16"], location = "eastus2" }
  }
}

module "bastion" {
  source = "../"
  depends_on = [
    module.vnet
  ]
  bastion = {
    host1 = {
      location              = "westeurope"
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      subnet_address_prefix = ["10.0.0.0/27"]
      existing = {
        vnetname = module.vnet.vnets.vnet1.name
        rgname   = "rg-network-dev-001"
      }
    }
    host2 = {
      location              = "eastus2"
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      subnet_address_prefix = ["10.0.1.0/27"]
      existing = {
        vnetname = module.vnet.vnets.vnet2.name
        rgname   = "rg-network-dev-001"
      }
    }
  }
}
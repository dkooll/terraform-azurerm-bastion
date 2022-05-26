provider "azurerm" {
  features {}
}

module "vnet" {
  source        = "github.com/dkooll/terraform-azurerm-vnet"
  resourcegroup = "rg-network-dev"
  vnets = {
    vnet1 = {
      cidr     = ["10.0.0.0/16"]
      location = "westeurope"
    }
  }
}

module "bastion" {
  source        = "github.com/dkooll/terraform-azurerm-bastion"
  depends_on    = [module.vnet]
  resourcegroup = "rg-bastion-dev"
  bastion = {
    host1 = {
      location              = "westeurope"
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      subnet_address_prefix = ["10.0.0.0/27"]
      existing = {
        vnetname = module.vnet.vnets.vnet1.name
        rgname   = module.vnet.resourcegroup
      }
    }
  }
}
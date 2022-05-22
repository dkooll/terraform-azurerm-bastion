provider "azurerm" {
  features {}
}

module "vnet" {
  source = "github.com/dkooll/terraform-azurerm-vnet"
  vnets = {
    vnet1 = {
      cidr     = ["10.0.0.0/16"]
      location = "westeurope"
    }
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
  }
}
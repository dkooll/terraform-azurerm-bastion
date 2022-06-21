provider "azurerm" {
  features {}
}

module "vnet" {
  source        = "github.com/dkooll/terraform-azurerm-vnet"
  version       = "1.1.0"
  resourcegroup = "rg-network-dev"
  vnets = {
    vnet1 = {
      cidr           = ["10.19.0.0/16"]
      location       = "eastus2"
      resource_group = "rg-network-eus2"
    }
  }
}

module "bastion" {
  #source     = "github.com/dkooll/terraform-azurerm-bastion"
  source     = "../../"
  depends_on = [module.vnet]
  bastion = {
    host1 = {
      location              = "eastus2"
      resourcegroup         = "rg-bastion-dev"
      subnet_address_prefix = ["10.19.0.0/27"]
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      existing = {
        vnetname = lookup(module.vnet["vnets"].vnet1["name"], null)
        rgname   = lookup(module.vnet["vnets"].vnet1["resource_group_name"], null)
      }
    }
  }
}
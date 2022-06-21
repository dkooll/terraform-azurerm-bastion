provider "azurerm" {
  features {}
}

module "network" {
  source        = "github.com/dkooll/terraform-azurerm-vnet?ref=1.1.0"
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
  source     = "../../"
  depends_on = [module.vnet]
  bastion = {
    host1 = {
      resourcegroup         = "rg-bastion-dev"
      location              = "eastus2"
      subnet_address_prefix = ["10.19.0.0/27"]
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      existing = {
        vnetname = lookup(module.network["vnets"].vnet1["name"], null)
        rgname   = lookup(module.network["vnets"].vnet1["resource_group_name"], null)
      }
    }
  }
}
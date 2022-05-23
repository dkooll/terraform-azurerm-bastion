![example workflow](https://github.com/dkooll/terraform-azurerm-bastion/actions/workflows/validate.yml/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Bastion Hosts `[Microsoft.Network/bastionHosts]`

Terraform module which creates bastion hosts on Azure.

## Table of Contents

- [Bastion Hosts](#bastion-hosts)
  - [**Table of Contents**](#table-of-contents)
  - [Resources](#resources)
  - [Inputs](#inputs)
    - [Usage: `single bastion host existing vnet`](#inputs-usage-single-bastion-hosts-existing-vnet)
    - [Usage: `multiple bastion hosts existing vnets`](#inputs-usage-multiple-bastion-hosts-existing-vnets)
  - [Outputs](#outputs)

## Resources

| Name | Type |
| :-- | :-- |
| `azurerm_resource_group` | resource |
| `azurerm_virtual_network` | datasource |
| `azurerm_subnet` | resource |
| `azurerm_public_ip` | resource |
| `azurerm_bastion_host` | resource |
| `azurerm_network_security_group` | resource |
| `azurerm_subnet_network_security_group_association` | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `bastion` | describes bastion related configuration | object | yes |
| `resourcegroup` | describes resourcegroup name | string | yes |

### Usage: `single bastion host existing vnet`

```terraform
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
```

### Usage: `multiple bastion hosts existing vnets`

```terraform
module "vnet" {
  source        = "github.com/dkooll/terraform-azurerm-vnet"
  resourcegroup = "rg-network-dev"
  vnets = {
    vnet1 = { cidr = ["10.0.0.0/16"], location = "westeurope" }
    vnet2 = { cidr = ["10.0.0.0/16"], location = "eastus2" }
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

    host2 = {
      location              = "eastus2"
      enable_copy_paste     = false
      enable_file_copy      = false
      enable_tunneling      = false
      subnet_address_prefix = ["10.0.0.0/27"]
      existing = {
        vnetname = module.vnet.vnets.vnet2.name
        rgname   = module.vnet.resourcegroup
      }
    }
  }
}
```

## Outputs

| Name | Description |
| :-- | :-- |
| `subnets` | contains all subnets |
| `vnets` | contains all vnets |

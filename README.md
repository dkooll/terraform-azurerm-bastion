![example workflow](https://github.com/dkooll/terraform-azurerm-bastion/actions/workflows/validate.yml/badge.svg)

## Bastion Hosts

Terraform module which creates bastion hosts on Azure.

## Usage: single bastion host existing vnet

```hcl
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

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network]() | datasource |
| [azurerm_subnet]() | resource |
| [azurerm_public_ip]() | resource |
| [azurerm_bastion_host]() | resource |
| [azurerm_network_security_group]() | resource |
| [azurerm_subnet_network_security_group_association]() | resource |

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_virtual_network]() | datasource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `bastion` | describes bastion related configuration | object | yes |
| `resourcegroup` | describes resourcegroup name | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `subnets` | contains all subnets |
| `vnets` | contains all vnets |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/dkooll/terraform-azurerm-bastion/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/dkooll/terraform-azurerm-bastion/tree/master/LICENSE) for full details.
bastion = {
  host1 = {
    location              = "eastus"
    enable_copy_paste     = false
    enable_file_copy      = false
    enable_tunneling      = false
    subnet_address_prefix = ["10.0.1.0/27"]
    existing = {
      vnetname = "vnet-dev-eastus"
      rgname   = "rg-existing-vnet"
    }
  }
}
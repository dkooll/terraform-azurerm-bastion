bastion = {
  host1 = {
    location = "eastus"
    vnet = {
      new      = { cidr = ["10.19.0.0/16"], subnet_cidr = ["10.19.1.224/27"] }
      # existing = { virtual_network_name = "", resource_group_name = "" }
    }
  }
}
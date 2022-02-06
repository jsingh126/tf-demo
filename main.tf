provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.hub_network.vnet_subnets[0]

  depends_on = [azurerm_resource_group.example]
}

module "windowsservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  is_windows_image    = true
  vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["winsimplevmips1"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.spoke_network.vnet_subnets[0]

  depends_on = [azurerm_resource_group.example]
}

module "hub_network" {
  source              = "Azure/network/azurerm"
  vnet_name = "hubnet"
  address_spaces = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["hub_subnet"]

  depends_on = [azurerm_resource_group.example]
}

module "spoke_network" {
  source              = "Azure/network/azurerm"
  address_spaces = ["10.2.0.0/16"]
  vnet_name = "spokenet"
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.2.0.0/24"]
  subnet_names        = ["spoke_subnet"]

  depends_on = [azurerm_resource_group.example]
}


output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
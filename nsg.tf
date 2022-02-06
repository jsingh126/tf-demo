locals {
  nsg_rules = csvdecode(file("${path.module}/nsg.csv"))
}


resource "azurerm_network_security_rule" "nsg" {
  for_each = {for frule in local.nsg_rules : frule.priority => frule}
  name = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port
  destination_port_range      = each.value.destination_port
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = module.linuxservers.network_security_group_name

}
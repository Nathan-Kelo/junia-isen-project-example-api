resource "random_integer" "ri" {
  min = 0
  max = 1000
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${random_integer.ri.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = false

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}


#I have no idea mashallah
# resource "azurerm_private_dns_zone" "dns" {
#   name                = "mydomain.com"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
#   name                  = "test"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.dns.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }
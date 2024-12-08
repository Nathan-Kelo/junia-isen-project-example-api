resource "random_integer" "ri" {
  min = 0
  max = 1000
}

#Create virtual network to host app service and CosmosDB
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${random_integer.ri.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

}

#Create subnet for the CosmosDB for private use only
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = false

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

#Create subnet for the app service available publicly
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      #The error message requested that I have this service delegated idk why
      name = "Microsoft.Web/serverFarms"
    }
  }
}
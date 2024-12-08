#Create random integer for unique names
resource "random_integer" "ri" {
  min = 0
  max = 1000
}

#Create resource group
resource "azurerm_resource_group" "test_rg" {
  name     = "rg-test-cloud-shop-project-${random_integer.ri.id}"
  location = "francecentral"
}

#Create virtual network
resource "azurerm_virtual_network" "test_vnet" {
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  name                = "test-vnet"
  address_space       = ["10.0.0.0/16"]
}

#Create subnet configured for private endpoints
resource "azurerm_subnet" "test_private_subnet" {
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  name                 = "test-private"
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = false

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

output "resource_group_name" {
  value = azurerm_resource_group.test_rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.test_vnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.test_private_subnet.id
}
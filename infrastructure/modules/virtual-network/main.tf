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

  //private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = false

  // This service endpoint is needed to create the private endpoint
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

  service_endpoints = ["Microsoft.Web"]

}

resource "azurerm_subnet" "gateway_subnet" {
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  #Dosent need a default name for gateway stuff and things
  name = "AppGatewaySubnet"

  #I think /28 is also strongly recommended to allow auto scaling
  address_prefixes = ["10.0.4.0/28"]

  service_endpoints = ["Microsoft.Web"]
}

# resource "azurerm_subnet" "firewall_subnet" {
#   resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   #Must have this default name
#   name = "AzureFirewallSubnet"

#   #I think /26 is also strongly recommended to allow auto scaling
#   address_prefixes = ["10.0.3.0/26"]
# }

# resource "azurerm_firewall" "firewall" {
#   resource_group_name = azurerm_virtual_network.vnet.resource_group_name
#   location            = azurerm_virtual_network.vnet.location
#   name                = "waf"
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.firewall_subnet.id
#     public_ip_address_id = azurerm_public_ip.ip.id
#   }
# }

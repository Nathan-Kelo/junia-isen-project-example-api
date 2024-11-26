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

# In way over my head
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
#Private connection to CosmosDB to protect database
resource "azurerm_private_endpoint" "cosmospe"{
  name = "cosmos-endpoint"
  location = var.location
  resource_group_name = var.resource_group_name
  subnet_id = azurerm_subnet.private.id

  #Select the resource to privately connect to
  private_service_connection {
    name="pe-cosmosdb-mongodb"
    private_connection_resource_id = var.cosmos_connection_resource_id
    is_manual_connection = false
    #MongoDB is the only choice, but can never be too explicit
    subresource_names = ["MongoDB"]
  }

  #Use the DNS defined below
  private_dns_zone_group {
    name="privatelink.mongodb.net"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }
}

#Create private DNS zone for private endpoint
resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.mongodb.net"
  resource_group_name = var.resource_group_name
}

#Link DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
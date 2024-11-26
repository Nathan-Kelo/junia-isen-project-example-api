resource "random_integer" "ri" {
  min = 0
  max = 1000
}

#Create the CosmosDB account with MongoDB enabled
resource "azurerm_cosmosdb_account" "acc" {
  name                = "cosmos-acc-${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  #Use a MongoDB instance
  kind = "MongoDB"

  automatic_failover_enabled = false
  # This is to make sure it is only available through the private network (maybe)
  public_network_access_enabled     = false
  is_virtual_network_filter_enabled = true

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  #Assign it to the private subnet
  virtual_network_rule {
    id = var.private_subnet_id
  }
}

#Create the MongoDB
resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = "mongo_${random_integer.ri.id}"
  resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
}

#Private connection to CosmosDB to protect database from public traffic
resource "azurerm_private_endpoint" "cosmospe" {
  name                = "cosmos-endpoint"
  location            = azurerm_cosmosdb_account.acc.location
  resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
  subnet_id           = var.private_subnet_id

  #Select the resource to privately connect to
  private_service_connection {
    name                           = "pe-cosmosdb-mongodb"
    private_connection_resource_id = azurerm_cosmosdb_account.acc.id
    is_manual_connection           = false
    #MongoDB is the only choice, but can never be too explicit
    subresource_names = ["MongoDB"]
  }

  #Use the DNS defined in the virtual-network module
  private_dns_zone_group {
    name                 = "privatelink.mongodb.net"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
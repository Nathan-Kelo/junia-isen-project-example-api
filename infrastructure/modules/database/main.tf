resource "random_integer" "ri" {
  min = 0
  max = 1000
}

resource "azurerm_cosmosdb_account" "acc" {
  name                = "cosmos-acc-${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "MongoDB"

  automatic_failover_enabled = false
  # This is to make sure it is only available through the private network (maybe)
  public_network_access_enabled = false
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

  virtual_network_rule {
    id = var.private_subnet
  }
}

resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = "mongo_${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
}

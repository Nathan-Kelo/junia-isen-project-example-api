resource "random_integer" "ri" {
  min = 0
  max = 10000
}

#Create the resoure group for the project
resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-shop-project-${random_integer.ri.id}"
  location = var.location
}

#Create the virtual network
module "vnet-1" {
  source              = "./modules/virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

#Create the database
module "database-1" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  private_subnet_id   = module.vnet-1.private_subnet_id
  vnet_id             = module.vnet-1.virtual_network_id
}

#Create the app
module "app-service-1" {
  source                  = "./modules/app-service"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  mongo_connection_string = module.database-1.connection_string
  cosmosdb_account_id     = module.database-1.cosmosdb_account_id
  subnet_id               = module.vnet-1.public_subnet_id
}

module "gateway-1" {
  source               = "./modules/gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  virtual_network_name = module.vnet-1.virtual_network_name
  gateway_subnet_id    = module.vnet-1.gateway_subnet_id
  app_service_fqdm     = module.app-service-1.app_url

}


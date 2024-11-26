resource "random_integer" "ri" {
  min = 0
  max = 10000
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-shop-project-${random_integer.ri.id}"
  location = var.location
}

module "database-1" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  private_subnet      = module.vnet-1.private_subnet
}

module "app-service-1" {
  source                  = "./modules/app-service"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  mongo_connection_string = module.database-1.connection_string
  identity_id             = module.database-1.identity_id
}

module "vnet-1" {
  source              = "./modules/virtual-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cosmos_connection_resource_id = module.database-1.identity_id
}
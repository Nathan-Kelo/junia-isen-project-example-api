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

#Create the virtual network
module "test_vnet" {
  source              = "../../modules/virtual-network"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
}

#Create the database
module "test_database" {
  source              = "../../modules/database"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = azurerm_resource_group.test_rg.location
  private_subnet_id   = module.test_vnet.private_subnet_id
  vnet_id             = module.test_vnet.virtual_network_id
}

#Create the app
module "test_app_service" {
  source                  = "../../modules/app-service"
  resource_group_name     = azurerm_resource_group.test_rg.name
  location                = azurerm_resource_group.test_rg.location
  mongo_connection_string = module.test_database.connection_string
  cosmosdb_account_id     = module.test_database.cosmosdb_account_id
  app_subnet_id           = module.test_vnet.public_subnet_id
  gateway_subnet_id       = module.test_vnet.gateway_subnet_id
  otel_exporter_otlp_headers = "dummy_value"
}

module "test_gateway" {
  source               = "../../modules/gateway"
  resource_group_name  = azurerm_resource_group.test_rg.name
  location             = azurerm_resource_group.test_rg.location
  virtual_network_name = module.test_vnet.virtual_network_name
  gateway_subnet_id    = module.test_vnet.gateway_subnet_id
  app_service_fqdm     = module.test_app_service.app_url
  app_subnet_id        = module.test_vnet.public_subnet_id
}

output "cosmos_url" {
  value = module.test_database.cosmos_acc_endpoint
}

output "app_url" {
  value = module.test_app_service.app_url
}

output "gateway_url" {
  value = module.test_gateway.gateway_frontend_ip
}
#Random number generator for unique resource names on the cloud
resource "random_integer" "ri" {
  min = 0
  max = 1000
}

#Create the service plan for the app
resource "azurerm_service_plan" "linuxplan" {
  name                = "lin-plan-${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

#Create the linux machine for the app to run
resource "azurerm_linux_web_app" "app" {
  name                      = "app-${random_integer.ri.id}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.linuxplan.id
  virtual_network_subnet_id = var.subnet_id

  #Pass the MongoDB URI to the application through the environment variables
  app_settings = tomap({
    MONGO_URL = var.mongo_connection_string
    }
  )

  site_config {
    #Setup docker deployment
    application_stack {
      docker_image_name   = "nathan-kelo/junia-isen-project-example-api:dev"
      docker_registry_url = "https://ghcr.io"
    }
  }
  #Set the Managed Identity to System
  identity {
    type = "SystemAssigned"
  }

}

#Custom role for RBAC of the app-service for the CosmosDB
resource "azurerm_role_definition" "mongo" {
  name        = "mongo-operator-${random_integer.ri.id}"
  scope       = var.cosmosdb_account_id
  description = "Custom role for MongoDB CRUD operations"

  permissions {
    actions = [
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/write",
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/read",
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/delete",
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections/write",
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections/delete",
      "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections/read"
    ]

    not_actions = []
  }
}

#Link the role to the Managed Identity of the app
resource "azurerm_role_assignment" "role" {
  principal_id = azurerm_linux_web_app.app.identity[0].principal_id
  description  = "Manged Identity connection to Cosmos DB."
  scope        = var.cosmosdb_account_id
  # Basic CRUD operations 
  role_definition_id = azurerm_role_definition.mongo.role_definition_resource_id
} 
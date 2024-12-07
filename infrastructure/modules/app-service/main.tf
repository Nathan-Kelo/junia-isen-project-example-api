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

  site_config {
    #TODO docker registry stuff and things here
    application_stack {
      python_version = "3.9"
      # docker_image_name = 
      # docker_registry_url = 
      # docker_registry_password =
      # docker_registry_username =  
    }


  }
  #Set the Managed Identity to System
  identity {
    type = "SystemAssigned"
  }

}

#Custom role for RBAC of the app-service for the CosmosDB
resource "azurerm_role_definition" "mongo" {
  name        = "mongo-operator"
  scope       = var.cosmosdb_account_id
  description = "Custom role for MongoDB CRUD operations"

  permissions {
    #TODO need to check if these shoudnt be data actions instead
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
#TODO dont know why when i check on the IAM of the rg and the cosmos app it appears
#but not in the app-service
resource "azurerm_role_assignment" "role" {
  principal_id = azurerm_linux_web_app.app.identity[0].principal_id
  description  = "Manged Identity connection to Cosmos DB."
  scope        = var.cosmosdb_account_id
  # Basic CRUD operations 
  role_definition_id = azurerm_role_definition.mongo.role_definition_resource_id
} 
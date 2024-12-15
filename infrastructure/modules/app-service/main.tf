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
  virtual_network_subnet_id = var.app_subnet_id
  #Deactivate public access so that it must pass through the gateway instead
  public_network_access_enabled = true



  app_settings = tomap({
    # Pass the MongoDB URI to the application through the environment variables
    MONGO_URL = var.mongo_connection_string,
    # Monitoring configuration
    OTEL_RESOURCE_ATTRIBUTES    = "service.name=cloudcomputing",
    OTEL_EXPORTER_OTLP_ENDPOINT = "https://ingest.eu.signoz.cloud:443",
    OTEL_EXPORTER_OTLP_HEADERS  = var.otel_exporter_otlp_headers,
    OTEL_EXPORTER_OTLP_PROTOCOL = "grpc"
    }
  )

  site_config {
    #Setup docker deployment
    application_stack {
      docker_image_name   = "nathan-kelo/junia-isen-project-example-api:dev"
      docker_registry_url = "https://ghcr.io"
    }


    # Ip restriction is inspired by these docs to route traffic through gateway
    # https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.web/web-app-with-app-gateway-v2/azuredeploy.json

    # Only accept from Gateway subnet
    ip_restriction {
      action                    = "Allow"
      name                      = "appGatewaySubnet"
      priority                  = 200
      virtual_network_subnet_id = var.gateway_subnet_id
      description               = "Isolate traffic to subnet containing Azure Application Gateway."
    }

    # Restrict from anywhere else
    ip_restriction_default_action = "Deny"

  }
  #Set the Managed Identity to System
  identity {
    type = "SystemAssigned"
  }



}

//WIP to create a private endpoint for app service to allow only specific traffic
/*
#Create private DNS zone for private endpoint
resource "azurerm_private_dns_zone" "dns" {
  #Private dns zone MUST follow a specific naming convention
  #https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

#Link DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "cosmospe" {
  name                = "cosmos-endpoint"
  location            = azurerm_cosmosdb_account.acc.location
  resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
  subnet_id           = var.private_subnet_id

  #Select the resource to privately connect to
  private_service_connection {
    name                           = "pe-cosmosdb-mongodb"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    is_manual_connection           = false
    #MongoDB is the only choice, but can never be too explicit
    subresource_names = ["sites"]
  }

  #Use the DNS defined in the virtual-network module
  private_dns_zone_group {
    name                 = "test-name-for-now"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }
}
*/


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
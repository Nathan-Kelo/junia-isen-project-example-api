resource "random_integer" "ri" {
  min = 0
  max = 1000
}

resource "azurerm_service_plan" "linuxplan" {
  name                = "lin-plan-${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${random_integer.ri.id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.linuxplan.id

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

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "role" {
  principal_id = azurerm_linux_web_app.app.identity[0].principal_id
  description  = "Manged Identity connection to Cosmos DB."
  scope        = var.identity_id
} 
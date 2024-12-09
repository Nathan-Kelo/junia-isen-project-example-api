provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "random" {

}

#Setup required infra to test database deployment
run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "private_configuration" {

  #Set input variables required to run database module
  variables {
    resource_group_name = run.setup.resource_group_name
    location            = "francecentral"
    private_subnet_id   = run.setup.private_subnet_id
    vnet_id             = run.setup.vnet_id
  }

  module {
    source = "./modules/database"
  }

  #Check public availability
  assert {
    condition     = azurerm_cosmosdb_account.acc.public_network_access_enabled == false
    error_message = "Database is available publicly."
  }
}


run "private_database" {
  variables {
    cosmos_endpoint = run.private_configuration.cosmos_acc_endpoint
  }

  module {
    source = "./tests/final"
  }

  assert {
    condition     = data.http.index.status_code != 200
    error_message = "Account is available publicly."
  }

}
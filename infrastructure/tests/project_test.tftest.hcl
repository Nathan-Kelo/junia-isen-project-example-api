provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "random" {

}

provider "http" {

}

#Setup required infra to test database deployment
run "setup" {
  module {
    source = "./tests/setup"
  }
}
run "endpoint_tests" {
  variables {
    cosmos_url  = run.setup.cosmos_url
    app_url     = run.setup.app_url
    gateway_url = run.setup.gateway_url
  }

  module {
    source = "./tests/final"
  }

  assert {
    condition     = data.http.cosmos.status_code != 200
    error_message = "Account is available publicly."
  }

  assert {
    condition     = data.http.app.status_code == 403
    error_message = "App service traffic is not routed through Gateway."
  }

  assert {
    condition     = data.http.gateway.status_code == 200
    error_message = "Gateway connection failed."
  }

  assert {
    condition     = data.http.gateway_hack.status_code == 403
    error_message = "Firewall not setup."
  }


}
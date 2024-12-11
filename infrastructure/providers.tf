terraform {
  required_version = ">=1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3"
    }
  }

}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }


  }
  subscription_id = var.subscription_id
}


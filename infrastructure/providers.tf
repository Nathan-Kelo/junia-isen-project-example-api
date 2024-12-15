terraform {
  required_version = ">=1.1.0"
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
  backend "azurerm" {
    resource_group_name  = "StateResourceGroup"
    storage_account_name = "statestorageaccount"
    container_name      = "state-container"
    key                 = "terraform.tfstate"
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


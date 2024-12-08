terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~>3"
    }
  }
}

variable "cosmos_endpoint" {
  type = string
}

data "http" "index" {
  url    = var.cosmos_endpoint
  method = "GET"
}
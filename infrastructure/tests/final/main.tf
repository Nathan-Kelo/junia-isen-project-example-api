terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~>3"
    }
  }
}

variable "cosmos_url" {
  type = string
}

variable "app_url" {
  type = string
}

variable "gateway_url" {
  type = string
}

# Ping CosmosDB to make sure it is unaccessible to public traffic
data "http" "cosmos" {
  url    = var.cosmos_url
  method = "GET"
}

# Ping App Service to make sure it is unaccessible to public traffic
data "http" "app" {
  url    = "http://${var.app_url}"
  method = "GET"
}

# Ping Gateway to make sure it is accessible to public traffic
data "http" "gateway" {
  url    = "http://${var.gateway_url}"
  method = "GET"
}

# Ping Gateway with an injection to make sure firewall is up
data "http" "gateway_hack" {
  # test=<script>alert('XSS Test');</script>
  url    = "http://${var.gateway_url}/?test=%3Cscript%3Ealert(%27XSS%20Test%27);%3C/script%3E"
  method = "GET"
}

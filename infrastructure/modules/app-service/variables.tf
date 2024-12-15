variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "mongo_connection_string" {
  type        = string
  description = "Connection string for the deployed mongo instance to pass into the docker image."
}

variable "cosmosdb_account_id" {
  type        = string
  description = "CosmosDB account id to link and create system identity."
}

variable "app_subnet_id" {
  type        = string
  description = "Virtual Network Id to connect the App on"
}

variable "gateway_subnet_id" {
  type        = string
  description = "Virtual Network of the gateway to restrict access."
}

variable "otel_exporter_otlp_headers" {
  type        = string
  description = "Secret access token for application monitoring authentification."
}
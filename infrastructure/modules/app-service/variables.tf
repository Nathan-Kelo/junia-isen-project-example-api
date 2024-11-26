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

variable "identity_id" {
  type = string
}
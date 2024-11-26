variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for provisioning ressources."
}

variable "location" {
  type        = string
  description = "Server location for all resources."
  default     = "francecentral"
}
output "connection_string" {
  value       = azurerm_cosmosdb_account.acc.primary_mongodb_connection_string
  description = "Connection string to connect to the mongo instance."
  sensitive   = true
}

output "cosmosdb_account_id" {
  value       = azurerm_cosmosdb_account.acc.id
  description = "Id of the role created to pass into the app service for scope designation."
}

output "cosmos_acc_endpoint" {
  value       = azurerm_cosmosdb_account.acc.endpoint
  description = "Cosmos endpoint to test that it is indeed private."
}
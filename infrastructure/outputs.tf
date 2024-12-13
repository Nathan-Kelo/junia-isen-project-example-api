output "app_url" {
  value = module.app-service-1.app_url
}

output "test_output" {
  value = module.vnet-1.public_subnet_id
}
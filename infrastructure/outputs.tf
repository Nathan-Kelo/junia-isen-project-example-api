output "app_url" {
  value = "http://${module.app-service-1.app_url}/"
}

output "gateway_frontend_ip" {
  value = "http://${module.gateway-1.gateway_frontend_ip}/"
}
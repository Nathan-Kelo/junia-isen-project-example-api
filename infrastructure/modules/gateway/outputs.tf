output "gateway_frontend_ip" {
  value = "http://${azurerm_public_ip.ip.ip_address}"
}
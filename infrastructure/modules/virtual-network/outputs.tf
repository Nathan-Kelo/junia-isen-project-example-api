output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway_subnet.id
}
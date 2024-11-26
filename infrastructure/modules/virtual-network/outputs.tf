output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_dns_zone_id"{
  value=azurerm_private_dns_zone.dns.id
}
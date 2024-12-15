# Create ip to associate to our application gateway
resource "azurerm_public_ip" "ip" {
  name                = "junia-cloud-the-best"
  location            = var.location
  resource_group_name = var.resource_group_name
  #Based on the documentation, public ip must have Static and Standard
  allocation_method = "Static"
  sku               = "Standard"

  # Give same zones to IP as Application Gateway for redundancy
  zones = [1, 2, 3]
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  backend_address_pool_name      = "${var.virtual_network_name}-beap"
  frontend_port_name             = "${var.virtual_network_name}-feport"
  frontend_ip_configuration_name = "${var.virtual_network_name}-feip"
  http_setting_name              = "${var.virtual_network_name}-be-htst"
  listener_name                  = "${var.virtual_network_name}-httplstn"
  request_routing_rule_name      = "${var.virtual_network_name}-rqrt"
  redirect_configuration_name    = "${var.virtual_network_name}-rdrcfg"
  probe_frontend_name            = "health-probe-frontend"
}

resource "azurerm_application_gateway" "gate" {
  name                = "gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = [1, 2, 3]

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  # Assign to dedicated subnet
  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.gateway_subnet_id
  }

  # Listen on 80 for Http traffic
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  # Create the pool with our app service in it
  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [var.app_service_fqdm]
  }

  probe {
    name = local.probe_frontend_name
    # Every 60s check on the app
    interval = 60
    # Wait 30s whether or not to declare it as unhealthy
    timeout = 30
    # Amount of times probe should fail before being labeled as unhealthy
    unhealthy_threshold = 1
    # We use the base path but should create a /health route only accessible to 
    # the gateway with whitelisting
    path                                      = "/health"
    protocol                                  = "Http"
    pick_host_name_from_backend_http_settings = true
  }

  backend_http_settings {
    pick_host_name_from_backend_address = true
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    probe_name                          = local.probe_frontend_name
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }


  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

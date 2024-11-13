resource "azurerm_frontdoor" "front_door" {
  name                = "${var.app_name}-frontdoor"
  resource_group_name = azurerm_resource_group.rg.name
  
  backend_pool {
    name = "backend-pool"
    health_probe_name = azurerm_resource_group.rg.name
    load_balancing_name = "backend-pool-lb"
    backend {
      address = azurerm_app_service.dotnet_webapi.default_site_hostname
      host_header = azurerm_app_service.dotnet_webapi.default_site_hostname
      http_port = 80
      https_port = 443
    }
  }

  backend_pool_health_probe {
    name = "health-probe"
    protocol = "Https"
    path = "/health"
    interval_in_seconds = 30
  }

  backend_pool_load_balancing {
    name = "backend-pool-lb"
    sample_size = 4
    successful_samples_required = 3
  }

  routing_rule {
    name = "routing-rule-1"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["frontend-endpoint"]
  }

  frontend_endpoint {
    name                              = "frontend-endpoint"
    host_name                         = "${var.app_name}-frontdoor.azurefd.net"
  }
}
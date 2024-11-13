resource "azurerm_app_service_plan" "app_plan" {
    name                = "${var.app_name}-plan"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    sku {   
        tier = var.app_tier
        size = var.app_size
    }
    maximum_elastic_worker_count = var.app_worker_count #Autoscaling enabled
    
}

resource "azurerm_app_service" "dotnet_webapi" {
    name                = var.app_name
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.app_plan.id
    https_only = true

    app_settings = {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.webapi_insights.connection_string
    }

    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_application_insights" "webapi_insights" {
    name = "${var.app_name}-insights"
    application_type = "web"
    resource_group_name = azurerm_resource_group.rg.name
     location = var.location
}

resource "azurerm_log_analytics_workspace" "webapi_logs" {
  name = "${var.app_name}-logs"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
}


resource "azurerm_monitor_autoscale_setting" "autoscale" {
    name = "${var.app_name}-autoscaling"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    target_resource_id = azurerm_app_service_plan.app_plan.id
    profile {
      name = "api-scaling"
      capacity {
        minimum = 1
        maximum = 10
        default = 5
      }

      rule {
        metric_trigger {
          metric_name = "CPU Usage"
          metric_resource_id = azurerm_app_service_plan.app_plan.id
          time_grain = "PT1M"
          time_window = "PT5M"
          statistic = "Average"
          time_aggregation = "Average"
          operator = "GreaterThan"
          threshold = 75
        }

        scale_action {
          direction = "Increase"
          type = "ChangeCount"
          value = "1"
          cooldown = "PT1M"
        }
      }

      rule {
        metric_trigger {
          metric_name = "CPU Usage"
          metric_resource_id = azurerm_app_service_plan.app_plan.id
          time_grain = "PT1M"
          time_window = "PT5M"
          statistic = "Average"
          time_aggregation = "Average"
          operator = "LessThan"
          threshold = 50
        }

        scale_action {
          direction = "Decrease"
          type = "ChangeCount"
          value = "1"
          cooldown = "PT1M"
        }
      }
    }
}

resource "azurerm_role_assignment" "API_access_db" {
  scope = azurerm_mssql_database.sql_db.id
  role_definition_name = "SQL DB Contributor"
  principal_id = azurerm_app_service.dotnet_webapi.identity.principal_id
}


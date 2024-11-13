resource "azurerm_mssql_server" "sql_server" {
    name                         = var.sql_server_name
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name
    administrator_login          = var.sql_admin_user
    administrator_login_password = var.sql_admin_password
    version                      = var.sql_version
    minimum_tls_version = 1.2

    azuread_administrator {
      login_username = "AzureAd Admin"
      object_id = "some 48 character long string of ID"
    }
}

resource "azurerm_mssql_server" "sql_server_secondary" {
    name                         = var.sql_server_name
    location                     = "ukwest"
    resource_group_name          = azurerm_resource_group.rg.name
    administrator_login          = var.sql_admin_user
    administrator_login_password = var.sql_admin_password
    version                      = var.sql_version
    minimum_tls_version = 1.2

    azuread_administrator {
      login_username = "AzureAd Admin"
      object_id = "some 48 character long string of ID"
    }
}

resource "azurerm_storage_account" "sql_backup_storage" {
  name = "${var.sql_server_name}-backups"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  account_replication_type = "GRS"
  account_tier = "Standard"
}

resource "azurerm_mssql_database" "sql_db" {
    name           = "${var.sql_server_name}-db"
    server_id      = azurerm_mssql_server.sql_server.id
    sku_name       = var.database_sku
    read_scale     = true
    read_replica_count = 1
    zone_redundant = true

    geo_backup_enabled = true

    long_term_retention_policy {
      week_of_year = 52
      weekly_retention = "P4W"
      monthly_retention = "P3M"
      yearly_retention = "P1Y"
    }

    lifecycle {
        prevent_destroy = true
    }

    transparent_data_encryption_enabled = true
}

resource "azurerm_mssql_failover_group" "failover_server_sql" {
  name = "${var.sql_server_name}-failover"
  server_id = azurerm_mssql_server.sql_server.id
  databases = [
    azurerm_mssql_database.sql_db.id
  ]
  partner_server {
    id = azurerm_mssql_server.sql_server_secondary.id
  }
  read_write_endpoint_failover_policy {
    mode = "Automatic"
    grace_minutes = 1
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "sql_db_extended_audit" {
  database_id = azurerm_mssql_database.sql_db.id
  storage_endpoint = azurerm_storage_account.sql_backup_storage.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.sql_backup_storage.primary_access_key
  retention_in_days = 30
}

resource "azurerm_log_analytics_workspace" "sql_analytics_workspace" {
  name = "${var.sql_server_name}-workspace"
  location = var.location
  resource_group_name = zurerm_resource_group.rg.name
}

resource "azurerm_monitor_diagnostic_setting" "audit_diagnostics" {
  name = "${var.sql_server_name}-audit"
  target_resource_id = azurerm_mssql_database.sql_db.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sql_analytics_workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}


# resource "azurerm_virtual_network" "sql_vnet" {
#   name =
#   resource_group_name =
#   location =
#   address_space = 
# }

# resource "azurerm_subnet" "sql_subnet" {
#   name =
#   resource_group_name =
#   virtual_network_name =
#   address_prefixes =
# }

# resource "azurerm_private_endpoint" "sql_priv_endpoint" {
  
# }

# resource "azurerm_private_endpoint_connection" "name" {
  
# }
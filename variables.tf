variable "location" {
    description = "Location"
    default = "uksouth"
}

variable "app_name" {
    description = "Azure App Service"
}

variable "app_tier" {
    description = "App tier"
    default = "Standard"
    type = "String"
}

variable "app_size" {
    description = "App Size"
    default = "S1"
    type = "String"
}

variable "app_worker_count" {
    description = "Count of workers for scaling App"
    default = 5
    type = number
}

variable "sql_server_name" {
    description = "SQL Server"
}

variable "sql_admin_user" {
    description = "SQL Admin User"
}

variable "sql_admin_password" {
    description = "SQL Admin Password"
    sensitive = true
}

variable "sql_version" {
    description = "SQL version"
}

variable "database_tier" {
    description = "Tier for DB"
    default = "Standard"
    type = "String"
}

variable "database_sku" {
    description = "Database SKU"
    default = "Basic"
}


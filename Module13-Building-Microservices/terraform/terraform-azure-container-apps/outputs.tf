# Module 13: Outputs for Azure Container Apps Microservices Deployment
# This file defines all output values from the Terraform deployment

# Unique Identifier
output "unique_id" {
  description = "Unique identifier for this deployment"
  value       = random_string.unique.result
}

# Resource Group Information
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.main.location
}

# Container Registry Information
output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

# Container Apps Environment
output "container_apps_environment_name" {
  description = "Name of the Container Apps Environment"
  value       = azurerm_container_app_environment.main.name
}

output "container_apps_environment_id" {
  description = "ID of the Container Apps Environment"
  value       = azurerm_container_app_environment.main.id
}

# SQL Server Information (only if use_sql_server = true)
output "sql_server_name" {
  description = "Name of the Azure SQL Server"
  value       = var.use_sql_server ? azurerm_mssql_server.main[0].name : "N/A - Using SQLite"
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = var.use_sql_server ? azurerm_mssql_server.main[0].fully_qualified_domain_name : "N/A - Using SQLite"
}

output "product_db_name" {
  description = "Name of the Product database"
  value       = var.use_sql_server ? azurerm_mssql_database.product_db[0].name : "SQLite file: /app/data/ecommerce.db"
}

output "order_db_name" {
  description = "Name of the Order database"
  value       = var.use_sql_server ? azurerm_mssql_database.order_db[0].name : "SQLite file: /app/data/ecommerce.db"
}

# Application Insights
output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

# Container Apps Service URLs
output "backend_url" {
  description = "URL for the Backend API (ECommerce.API)"
  value       = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
}

output "frontend_url" {
  description = "URL for the Frontend Application"
  value       = "https://${azurerm_container_app.frontend.ingress[0].fqdn}"
}

# Service Discovery
output "backend_internal_url" {
  description = "Internal URL for Backend API (for service-to-service communication)"
  value       = "http://ecommerce-backend"
}

output "frontend_internal_url" {
  description = "Internal URL for Frontend (for service-to-service communication)"
  value       = "http://ecommerce-frontend"
}

output "redis_internal_url" {
  description = "Internal URL for Redis (for service-to-service communication)"
  value       = "ecommerce-redis:6379"
}

# Connection Strings (for local development/testing)
output "product_db_connection_string" {
  description = "Connection string for Product database"
  value       = "See terraform.tfvars for database configuration"
  sensitive   = true
}

output "order_db_connection_string" {
  description = "Connection string for Order database"
  value       = "See terraform.tfvars for database configuration"
  sensitive   = true
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for the deployed resources"
  value = var.use_sql_server ? "Container Apps (3 apps including Redis): ~$15\nAzure SQL (Basic tier, 2 databases): ~$10\nContainer Registry (Basic tier): ~$5\nApplication Insights (Basic ingestion): ~$5\nTotal: ~$35/month (minimal usage)" : "Container Apps (3 apps including Redis): ~$15\nContainer Registry (Basic tier): ~$5\nApplication Insights (Basic ingestion): ~$5\nTotal: ~$25/month (minimal usage)\nNote: Using SQLite - no database costs!"
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    resource_group         = azurerm_resource_group.main.name
    container_registry     = azurerm_container_registry.main.name
    backend_url            = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
    frontend_url           = "https://${azurerm_container_app.frontend.ingress[0].fqdn}"
    application_insights   = azurerm_application_insights.main.name
    estimated_monthly_cost = var.use_sql_server ? "~$30" : "~$25"
  }
}
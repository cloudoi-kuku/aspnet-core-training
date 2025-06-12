# Module 13: Building Microservices with Azure Container Apps
# This Terraform configuration replaces the PowerShell launch scripts
# and provides a complete Infrastructure as Code solution

terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Local variables for consistent naming and tagging
locals {
  # Generate unique resource suffix
  unique_suffix = random_string.unique.result
  
  # Merge common tags
  tags = merge(
    var.common_tags,
    var.tags,
    {
      UniqueId  = local.unique_suffix
      CreatedBy = "Terraform"
      BaseName  = var.base_name
    }
  )
  
  # Database connection string - simplified to avoid complex conditionals
  db_connection_string = "Data Source=/app/data/ecommerce.db"
}

# Random string for unique resource identification
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.base_name}-${local.unique_suffix}"
  location = var.location
  tags     = local.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${var.base_name}${local.unique_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

# Log Analytics Workspace for Container Apps Environment
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.base_name}-${local.unique_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${var.base_name}-${local.unique_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
  tags                = local.tags
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.base_name}-${local.unique_suffix}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

# Azure SQL Server (Optional - only if use_sql_server = true)
resource "azurerm_mssql_server" "main" {
  count                        = var.use_sql_server ? 1 : 0
  name                         = "sql-${var.base_name}-${local.unique_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  tags                         = local.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_admin_login != "" && var.azuread_admin_object_id != "" ? [1] : []
    content {
      login_username = var.azuread_admin_login
      object_id      = var.azuread_admin_object_id
    }
  }
}

# Firewall rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.use_sql_server ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Product Database
resource "azurerm_mssql_database" "product_db" {
  count        = var.use_sql_server ? 1 : 0
  name         = "ProductDb"
  server_id    = azurerm_mssql_server.main[0].id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name     = "Basic"
  tags         = local.tags
}

# Order Database
resource "azurerm_mssql_database" "order_db" {
  count        = var.use_sql_server ? 1 : 0
  name         = "OrderDb"
  server_id    = azurerm_mssql_server.main[0].id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name     = "Basic"
  tags         = local.tags
}

# Build and push Docker images to ACR
resource "null_resource" "build_images" {
  depends_on = [azurerm_container_registry.main]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login to ACR
      az acr login --name ${azurerm_container_registry.main.name}
      
      # Build and push Backend (ECommerce.API)
      cd ${path.module}/../src/backend/ECommerce.API
      az acr build --registry ${azurerm_container_registry.main.name} --image ecommerce-backend:latest . --platform linux/amd64
      
      # Build and push Frontend (without API URL - will be set in second phase)
      cd ${path.module}/../src/frontend
      az acr build --registry ${azurerm_container_registry.main.name} --image ecommerce-frontend:latest . --platform linux/amd64
    EOT
  }
}

# Backend Container App (ECommerce.API)
resource "azurerm_container_app" "backend" {
  name                         = "ecommerce-backend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  depends_on = [null_resource.build_images, azurerm_container_app.redis]

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.main.admin_password
  }

  secret {
    name  = "db-connection"
    value = local.db_connection_string
  }

  secret {
    name  = "redis-connection"
    value = coalesce(var.redis_connection_string, "ecommerce-redis:6379")
  }

  secret {
    name  = "jwt-secret"
    value = coalesce(var.jwt_secret_key, "your-super-secret-jwt-key-change-this-in-production")
  }

  secret {
    name  = "app-insights-key"
    value = azurerm_application_insights.main.instrumentation_key
  }

  template {
    container {
      name   = "backend"
      image  = "${azurerm_container_registry.main.login_server}/ecommerce-backend:latest"
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:5050"
      }

      env {
        name        = "ConnectionStrings__DefaultConnection"
        secret_name = "db-connection"
      }

      env {
        name        = "ConnectionStrings__Redis"
        secret_name = "redis-connection"
      }

      env {
        name        = "JwtSettings__SecretKey"
        secret_name = "jwt-secret"
      }

      env {
        name  = "JwtSettings__Issuer"
        value = "ecommerce-api"
      }

      env {
        name  = "JwtSettings__Audience"
        value = "ecommerce-app"
      }

      env {
        name        = "ApplicationInsights__InstrumentationKey"
        secret_name = "app-insights-key"
      }

      env {
        name  = "CORS__AllowedOrigins__0"
        value = "https://ecommerce-frontend.${azurerm_container_app_environment.main.default_domain}"
      }

      env {
        name  = "CORS__AllowedOrigins__1"
        value = "http://localhost:3000"
      }

      liveness_probe {
        path            = "/health/live"
        port            = 5050
        transport       = "HTTP"
        interval_seconds = 10
      }

      readiness_probe {
        path            = "/api/health"
        port            = 5050
        transport       = "HTTP"
        interval_seconds = 5
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = "100"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 5050
    transport        = "http"

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

# Redis Container App
resource "azurerm_container_app" "redis" {
  name                         = "ecommerce-redis"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  template {
    container {
      name   = "redis"
      image  = "redis:7-alpine"
      cpu    = 0.25
      memory = "0.5Gi"

      liveness_probe {
        transport = "TCP"
        port      = 6379
        interval_seconds = 10
      }

      readiness_probe {
        transport = "TCP"
        port      = 6379
        interval_seconds = 5
      }
    }

    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    external_enabled = false
    target_port      = 6379
    transport        = "tcp"

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

# Frontend Container App
resource "azurerm_container_app" "frontend" {
  name                         = "ecommerce-frontend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  depends_on = [null_resource.build_images, azurerm_container_app.backend]

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.main.admin_password
  }

  template {
    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.main.login_server}/ecommerce-frontend:latest"
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "NEXT_PUBLIC_API_URL"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }

      env {
        name  = "API_BASE_URL"
        value = "http://ecommerce-backend"
      }

      env {
        name  = "PORT"
        value = "3000"
      }

      env {
        name  = "HOSTNAME"
        value = "0.0.0.0"
      }

      liveness_probe {
        path            = "/"
        port            = 3000
        transport       = "HTTP"
        interval_seconds = 10
      }

      readiness_probe {
        path            = "/api/health"
        port            = 3000
        transport       = "HTTP"
        interval_seconds = 5
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    http_scale_rule {
      name                = "http-scale"
      concurrent_requests = "100"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "http"

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

# Generate configuration file (similar to azure-config.ps1) - removed to avoid conditional resource references
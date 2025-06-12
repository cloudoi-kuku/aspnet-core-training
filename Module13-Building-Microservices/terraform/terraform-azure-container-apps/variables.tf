# Module 13: Variables for Azure Container Apps Microservices Deployment
# This file defines all input variables for the Terraform configuration

# Base name for resources
variable "base_name" {
  description = "Base name for resources (will be appended with random suffix)"
  type        = string
  default     = "microservices"
}

# Azure Region
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westus"
}

# Common Tags (Required by organization policy)
variable "common_tags" {
  description = "Common tags for all resources (required by organization policy)"
  type        = map(string)
  default = {
    ManagedBy             = "Terraform"
    Environment           = "Training"
    Project              = "Microservices"
    Module               = "Module13"
    "enablon:client"      = "Enablon Internal"
    "enablon:cost_center" = "IT-Training"
    "enablon:owner"       = "DevOps Team"
    "enablon:contact"     = "training@company.com"
  }
}

# Database Configuration
variable "use_sql_server" {
  description = "Use SQL Server instead of SQLite (increases cost)"
  type        = bool
  default     = false
}

# SQL Server Configuration (only used if use_sql_server = true)
variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Administrator password for SQL Server (required if use_sql_server = true)"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd123!"
}

# Azure AD Configuration for SQL Server
variable "azuread_admin_login" {
  description = "Azure AD admin login for SQL Server"
  type        = string
  default     = ""
}

variable "azuread_admin_object_id" {
  description = "Azure AD admin object ID for SQL Server"
  type        = string
  default     = ""
}

# Container App Configuration
variable "container_cpu" {
  description = "CPU allocation for container apps (in cores)"
  type        = number
  default     = 0.5
  validation {
    condition     = contains([0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], var.container_cpu)
    error_message = "Container CPU must be one of: 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0"
  }
}

variable "container_memory" {
  description = "Memory allocation for container apps (e.g., '1.0Gi')"
  type        = string
  default     = "1.0Gi"
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?Gi$", var.container_memory))
    error_message = "Container memory must be in format like '1.0Gi' or '2.0Gi'."
  }
}

# Scaling Configuration
variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 1
  validation {
    condition     = var.min_replicas >= 0
    error_message = "Minimum replicas must be 0 or greater."
  }
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 3
  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 30
    error_message = "Maximum replicas must be between 1 and 30."
  }
}

# Additional Tags
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Feature Flags
variable "enable_monitoring" {
  description = "Enable Application Insights and monitoring"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for container apps"
  type        = bool
  default     = true
}

# Service Discovery
variable "enable_service_discovery" {
  description = "Enable service discovery between microservices"
  type        = bool
  default     = true
}

# Redis Configuration
variable "redis_connection_string" {
  description = "Redis connection string (optional - will use default if not provided)"
  type        = string
  default     = null
}

# JWT Configuration
variable "jwt_secret_key" {
  description = "JWT secret key for authentication"
  type        = string
  sensitive   = true
  default     = null
}
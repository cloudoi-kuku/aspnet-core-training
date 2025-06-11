# General Variables
variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

# Environment Configuration
variable "environments" {
  type = map(object({
    aks_node_count     = number
    aks_min_count      = number
    aks_max_count      = number
    aks_vm_size        = string
    sql_sku            = string
    sql_max_size_gb    = number
    servicebus_sku     = string
  }))
  
  default = {
    dev = {
      aks_node_count  = 1
      aks_min_count   = 1
      aks_max_count   = 3
      aks_vm_size     = "Standard_D2s_v3"
      sql_sku         = "Basic"
      sql_max_size_gb = 2
      servicebus_sku  = "Basic"
    }
    staging = {
      aks_node_count  = 2
      aks_min_count   = 2
      aks_max_count   = 5
      aks_vm_size     = "Standard_D4s_v3"
      sql_sku         = "S1"
      sql_max_size_gb = 32
      servicebus_sku  = "Standard"
    }
    production = {
      aks_node_count  = 3
      aks_min_count   = 3
      aks_max_count   = 10
      aks_vm_size     = "Standard_D4s_v3"
      sql_sku         = "S3"
      sql_max_size_gb = 100
      servicebus_sku  = "Premium"
    }
  }
}

# Networking Variables
variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the virtual network"
}

variable "subnet_prefixes" {
  type = map(list(string))
  default = {
    aks      = ["10.0.1.0/24"]
    database = ["10.0.2.0/24"]
    appgw    = ["10.0.3.0/24"]
  }
  description = "Subnet address prefixes"
}

# AKS Configuration
variable "kubernetes_version" {
  type        = string
  default     = "1.30.12"
  description = "Kubernetes version for AKS"
}

variable "enable_auto_scaling" {
  type        = bool
  default     = true
  description = "Enable auto-scaling for AKS node pools"
}

# Database Configuration
variable "sql_admin_username" {
  type        = string
  default     = "sqladmin"
  description = "SQL Server admin username"
}

variable "enable_sql_firewall_rules" {
  type        = bool
  default     = true
  description = "Enable SQL Server firewall rules"
}

# Security Configuration
variable "enable_pod_security_policy" {
  type        = bool
  default     = false
  description = "Enable Pod Security Policy for AKS"
}

variable "enable_azure_policy" {
  type        = bool
  default     = true
  description = "Enable Azure Policy for AKS"
}

# Monitoring Configuration
variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain logs"
}

variable "enable_diagnostic_settings" {
  type        = bool
  default     = true
  description = "Enable diagnostic settings for resources"
}

# Tags
variable "common_tags" {
  type = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "Production"
    Project     = "ECommerce-Microservices"
    CostCenter  = "IT"
    Owner       = "DevOps Team"
    "enablon:contact"     = "your email"
    "enablon:owner"       = "Environmental"
    "enablon:client"      = "Enablon Internal"
    "enablon:cost_center" = "Environmental"
  }
  description = "Common tags for all resources"
}

# Application Configuration
variable "microservices" {
  type = map(object({
    image_tag     = string
    replicas      = number
    cpu_request   = string
    cpu_limit     = string
    memory_request = string
    memory_limit   = string
    port          = number
  }))
  
  default = {
    product-catalog = {
      image_tag      = "latest"
      replicas       = 3
      cpu_request    = "100m"
      cpu_limit      = "500m"
      memory_request = "128Mi"
      memory_limit   = "512Mi"
      port           = 80
    }
    order-management = {
      image_tag      = "latest"
      replicas       = 3
      cpu_request    = "100m"
      cpu_limit      = "500m"
      memory_request = "128Mi"
      memory_limit   = "512Mi"
      port           = 80
    }
    user-management = {
      image_tag      = "latest"
      replicas       = 2
      cpu_request    = "100m"
      cpu_limit      = "300m"
      memory_request = "128Mi"
      memory_limit   = "256Mi"
      port           = 80
    }
    notification-service = {
      image_tag      = "latest"
      replicas       = 2
      cpu_request    = "50m"
      cpu_limit      = "200m"
      memory_request = "64Mi"
      memory_limit   = "256Mi"
      port           = 80
    }
    api-gateway = {
      image_tag      = "latest"
      replicas       = 3
      cpu_request    = "200m"
      cpu_limit      = "1000m"
      memory_request = "256Mi"
      memory_limit   = "1Gi"
      port           = 80
    }
  }
}

# Feature Flags
variable "enable_service_mesh" {
  type        = bool
  default     = false
  description = "Enable service mesh (Istio) for AKS"
}

variable "enable_external_dns" {
  type        = bool
  default     = true
  description = "Enable external DNS for automatic DNS management"
}

variable "enable_backup" {
  type        = bool
  default     = true
  description = "Enable backup for databases and persistent volumes"
}

# DNS Configuration
variable "domain_name" {
  type        = string
  default     = ""
  description = "Domain name for the application (optional)"
}

variable "subdomain" {
  type        = string
  default     = "api"
  description = "Subdomain for the API gateway"
}
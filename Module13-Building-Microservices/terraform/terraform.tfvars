# Azure Configuration
subscription_id = "vvv"
tenant_id       = "xxx"


# Resource Configuration
resource_group_name = "bisiecommerce-microservices-rg"
location            = "West US 2"
environment         = "production"
project_name        = "ecommerce"

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]
subnet_prefixes = {
  aks      = ["10.0.1.0/24"]
  database = ["10.0.2.0/24"]
  appgw    = ["10.0.3.0/24"]
}

# AKS Configuration
kubernetes_version  = "1.30.12"
enable_auto_scaling = true

# Database Configuration
sql_admin_username        = "sqladmin"
enable_sql_firewall_rules = true

# Security Configuration
enable_pod_security_policy = false
enable_azure_policy        = true

# Monitoring Configuration
log_retention_days         = 30
enable_diagnostic_settings = true

# Domain Configuration (optional)
# domain_name = "mycompany.com"
# subdomain   = "api"

# Feature Flags
enable_service_mesh  = false
enable_external_dns  = true
enable_backup        = true

# Tags
common_tags = {
  ManagedBy                 = "Terraform"
  Environment              = "Production"
  Project                  = "ECommerce-Microservices"
  CostCenter               = "IT"
  Owner                    = "DevOps Team"
  "enablon:contact"        = "your email"
  "enablon:owner"          = "Environmental"
  "enablon:client"         = "Enablon Internal"
  "enablon:cost_center"    = "Environmental"
}

# Microservices Configuration
microservices = {
  product-catalog = {
    image_tag      = "v1.0.0"
    replicas       = 3
    cpu_request    = "100m"
    cpu_limit      = "500m"
    memory_request = "128Mi"
    memory_limit   = "512Mi"
    port           = 80
  }
  order-management = {
    image_tag      = "v1.0.0"
    replicas       = 3
    cpu_request    = "100m"
    cpu_limit      = "500m"
    memory_request = "128Mi"
    memory_limit   = "512Mi"
    port           = 80
  }
  user-management = {
    image_tag      = "v1.0.0"
    replicas       = 2
    cpu_request    = "100m"
    cpu_limit      = "300m"
    memory_request = "128Mi"
    memory_limit   = "256Mi"
    port           = 80
  }
  notification-service = {
    image_tag      = "v1.0.0"
    replicas       = 2
    cpu_request    = "50m"
    cpu_limit      = "200m"
    memory_request = "64Mi"
    memory_limit   = "256Mi"
    port           = 80
  }
  api-gateway = {
    image_tag      = "v1.0.0"
    replicas       = 3
    cpu_request    = "200m"
    cpu_limit      = "1000m"
    memory_request = "256Mi"
    memory_limit   = "1Gi"
    port           = 80
  }
}
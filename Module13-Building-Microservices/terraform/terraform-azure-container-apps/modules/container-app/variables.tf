# Variables for Container App Module

variable "name" {
  description = "Name of the container app"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the Container App Environment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "revision_mode" {
  description = "Revision mode for the container app"
  type        = string
  default     = "Single"
}

variable "tags" {
  description = "Tags to apply to the container app"
  type        = map(string)
  default     = {}
}

# Registry Configuration
variable "registry_server" {
  description = "Container registry server"
  type        = string
  default     = null
}

variable "registry_username" {
  description = "Container registry username"
  type        = string
  default     = null
}

variable "registry_password" {
  description = "Container registry password"
  type        = string
  sensitive   = true
  default     = null
}

# Container Configuration
variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "container_cpu" {
  description = "CPU allocation for the container"
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Memory allocation for the container"
  type        = string
  default     = "1.0Gi"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

# Environment and Secrets
variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name        = string
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "Secrets for the container app"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# Scaling Configuration
variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 3
}

variable "enable_http_scale_rule" {
  description = "Enable HTTP-based scaling"
  type        = bool
  default     = true
}

variable "http_scale_concurrent_requests" {
  description = "Number of concurrent requests for HTTP scaling"
  type        = string
  default     = "10"
}

variable "custom_scale_rules" {
  description = "Custom scale rules"
  type = list(object({
    name     = string
    type     = string
    metadata = map(string)
  }))
  default = []
}

# Health Checks
variable "enable_health_checks" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "liveness_probe_path" {
  description = "Path for liveness probe"
  type        = string
  default     = "/health"
}

variable "liveness_probe_initial_delay" {
  description = "Initial delay for liveness probe (seconds)"
  type        = number
  default     = 30
}

variable "liveness_probe_interval" {
  description = "Interval for liveness probe (seconds)"
  type        = number
  default     = 10
}

variable "readiness_probe_path" {
  description = "Path for readiness probe"
  type        = string
  default     = "/health/ready"
}

variable "readiness_probe_initial_delay" {
  description = "Initial delay for readiness probe (seconds)"
  type        = number
  default     = 5
}

variable "readiness_probe_interval" {
  description = "Interval for readiness probe (seconds)"
  type        = number
  default     = 5
}

# Ingress Configuration
variable "enable_ingress" {
  description = "Enable ingress for the container app"
  type        = bool
  default     = true
}

variable "ingress_external_enabled" {
  description = "Enable external ingress"
  type        = bool
  default     = true
}

variable "ingress_transport" {
  description = "Transport protocol for ingress"
  type        = string
  default     = "http"
}
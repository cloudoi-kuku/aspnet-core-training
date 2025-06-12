# Reusable Module for Container App Deployment
# This module encapsulates the container app deployment logic

resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = var.tags

  dynamic "registry" {
    for_each = var.registry_server != null ? [1] : []
    content {
      server               = var.registry_server
      username             = var.registry_username
      password_secret_name = "registry-password"
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  template {
    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name        = env.value.name
          value       = lookup(env.value, "value", null)
          secret_name = lookup(env.value, "secret_name", null)
        }
      }

      dynamic "liveness_probe" {
        for_each = var.enable_health_checks ? [1] : []
        content {
          path             = var.liveness_probe_path
          port             = var.container_port
          transport        = "HTTP"
          initial_delay    = var.liveness_probe_initial_delay
          interval_seconds = var.liveness_probe_interval
        }
      }

      dynamic "readiness_probe" {
        for_each = var.enable_health_checks ? [1] : []
        content {
          path             = var.readiness_probe_path
          port             = var.container_port
          transport        = "HTTP"
          initial_delay    = var.readiness_probe_initial_delay
          interval_seconds = var.readiness_probe_interval
        }
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "http_scale_rule" {
      for_each = var.enable_http_scale_rule ? [1] : []
      content {
        name                = "http-scale"
        concurrent_requests = var.http_scale_concurrent_requests
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.custom_scale_rules
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.type
        metadata         = custom_scale_rule.value.metadata
      }
    }
  }

  dynamic "ingress" {
    for_each = var.enable_ingress ? [1] : []
    content {
      external_enabled = var.ingress_external_enabled
      target_port      = var.container_port
      transport        = var.ingress_transport

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}
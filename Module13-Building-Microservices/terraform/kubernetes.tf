
# Namespaces - Commented out to avoid provider connection issues
# These will be created by the Helm deployment script instead
# resource "kubernetes_namespace" "apps" {
#   metadata {
#     name = "ecommerce-apps"
#     labels = {
#       environment = var.environment
#       managed-by  = "terraform"
#     }
#   }
# }

# resource "kubernetes_namespace" "ingress" {
#   metadata {
#     name = "ingress-nginx"
#   }
# }

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# NGINX Ingress Controller - deployed via Helm script
# See deploy-with-helm.sh for installation

# Prometheus and Grafana - deployed via Helm script
# See deploy-with-helm.sh for installation

# Random password removed - using fixed password in Helm deployment script

# ConfigMap for Application Configuration - Commented out to avoid provider connection issues
# This will be created by the Helm deployment script instead
# resource "kubernetes_config_map" "app_config" {
#   metadata {
#     name      = "app-config"
#     namespace = "ecommerce-apps"
#   }
#
#   data = {
#     "appsettings.Production.json" = jsonencode({
#       ApplicationInsights = {
#         InstrumentationKey = azurerm_application_insights.main.instrumentation_key
#       }
#       ServiceBus = {
#         ConnectionString = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/servicebus-connection-string/)"
#       }
#       SqlServer = {
#         Server = azurerm_mssql_server.main.fully_qualified_domain_name
#       }
#     })
#   }
# }



# Cert-Manager for TLS - deployed via Helm script
# See deploy-with-helm.sh for installation



# Horizontal Pod Autoscaler for services - Commented out to avoid provider connection issues
# This will be created by the Helm deployment script instead
# resource "kubernetes_horizontal_pod_autoscaler_v2" "product_catalog_hpa" {
#   metadata {
#     name      = "product-catalog-hpa"
#     namespace = "ecommerce-apps"
#   }
#
#   spec {
#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "product-catalog"
#     }
#
#     min_replicas = 3
#     max_replicas = 10
#
#     metric {
#       type = "Resource"
#
#       resource {
#         name = "cpu"
#         target {
#           type                = "Utilization"
#           average_utilization = 70
#         }
#       }
#     }
#
#     metric {
#       type = "Resource"
#
#       resource {
#         name = "memory"
#         target {
#           type                = "Utilization"
#           average_utilization = 80
#         }
#       }
#     }
#
#     behavior {
#       scale_up {
#         stabilization_window_seconds = 60
#         select_policy               = "Max"
#
#         policy {
#           type          = "Percent"
#           value         = 100
#           period_seconds = 15
#         }
#       }
#
#       scale_down {
#         stabilization_window_seconds = 300
#         select_policy               = "Min"
#
#         policy {
#           type          = "Percent"
#           value         = 10
#           period_seconds = 60
#         }
#       }
#     }
#   }
# }

# Pod Disruption Budget - Commented out to avoid provider connection issues
# This will be created by the Helm deployment script instead
# resource "kubernetes_pod_disruption_budget_v1" "product_catalog_pdb" {
#   metadata {
#     name      = "product-catalog-pdb"
#     namespace = "ecommerce-apps"
#   }
#
#   spec {
#     min_available = 2
#
#     selector {
#       match_labels = {
#         app = "product-catalog"
#       }
#     }
#   }
# }

# Network Policies - Commented out to avoid provider connection issues
# These will be created by the Helm deployment script instead
# resource "kubernetes_network_policy" "default_deny" {
#   metadata {
#     name      = "default-deny"
#     namespace = "ecommerce-apps"
#   }
#
#   spec {
#     pod_selector {}
#     policy_types = ["Ingress", "Egress"]
#   }
# }

# resource "kubernetes_network_policy" "allow_ingress" {
#   metadata {
#     name      = "allow-from-ingress"
#     namespace = "ecommerce-apps"
#   }
#
#   spec {
#     pod_selector {
#       match_labels = {
#         "app.kubernetes.io/part-of" = "ecommerce"
#       }
#     }
#
#     policy_types = ["Ingress"]
#
#     ingress {
#       from {
#         namespace_selector {
#           match_labels = {
#             name = "ingress-nginx"
#           }
#         }
#       }
#     }
#   }
# }

# Apply Kubernetes manifests using kubectl after cluster is ready
resource "null_resource" "apply_manifests" {
  depends_on = [
    azurerm_kubernetes_cluster.main
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Get AKS credentials
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing

      # Apply Secret Provider Class
      kubectl apply -f - <<EOF
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault-secrets
  namespace: ecommerce-apps
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: ${azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id}
    keyvaultName: ${azurerm_key_vault.main.name}
    tenantId: ${data.azurerm_client_config.current.tenant_id}
    objects: |
      array:
        - |
          objectName: sql-connection-string
          objectType: secret
        - |
          objectName: servicebus-connection-string
          objectType: secret
        - |
          objectName: appinsights-instrumentation-key
          objectType: secret
  secretObjects:
  - secretName: app-secrets
    type: Opaque
    data:
    - objectName: sql-connection-string
      key: SqlConnectionString
    - objectName: servicebus-connection-string
      key: ServiceBusConnectionString
    - objectName: appinsights-instrumentation-key
      key: AppInsightsKey
EOF

      # Apply Let's Encrypt ClusterIssuer
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@${var.project_name}.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

      # Apply Service Monitor
      kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ecommerce-apps
  namespace: ecommerce-apps
  labels:
    release: prometheus-stack
spec:
  selector:
    matchLabels:
      app.kubernetes.io/part-of: ecommerce
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF
    EOT
  }

  # Cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete secretproviderclass azure-keyvault-secrets -n ecommerce-apps --ignore-not-found=true
      kubectl delete clusterissuer letsencrypt-prod --ignore-not-found=true
      kubectl delete servicemonitor ecommerce-apps -n ecommerce-apps --ignore-not-found=true
    EOT
  }
}


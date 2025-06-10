
# Namespaces
resource "kubernetes_namespace" "apps" {
  metadata {
    name = "ecommerce-apps"
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  version    = "4.8.3"
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
  
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  
  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }
}

# Install Prometheus and Grafana
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "54.0.0"
  
  values = [
    file("${path.module}/helm-values/prometheus-values.yaml")
  ]
  
  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana_admin_password.result
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "managed-premium"
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "50Gi"
  }
}

resource "random_password" "grafana_admin_password" {
  length  = 16
  special = true
}

# ConfigMap for Application Configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }
  
  data = {
    "appsettings.Production.json" = jsonencode({
      ApplicationInsights = {
        InstrumentationKey = azurerm_application_insights.main.instrumentation_key
      }
      ServiceBus = {
        ConnectionString = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.main.vault_uri}secrets/servicebus-connection-string/)"
      }
      SqlServer = {
        Server = azurerm_mssql_server.main.fully_qualified_domain_name
      }
    })
  }
}



# Install Cert-Manager for TLS
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.13.2"
  
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  set {
    name  = "prometheus.enabled"
    value = "true"
  }
}



# Horizontal Pod Autoscaler for services
resource "kubernetes_horizontal_pod_autoscaler_v2" "product_catalog_hpa" {
  metadata {
    name      = "product-catalog-hpa"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "product-catalog"
    }
    
    min_replicas = 3
    max_replicas = 10
    
    metric {
      type = "Resource"
      
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
    
    metric {
      type = "Resource"
      
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
    
    behavior {
      scale_up {
        stabilization_window_seconds = 60
        select_policy               = "Max"
        
        policy {
          type          = "Percent"
          value         = 100
          period_seconds = 15
        }
      }
      
      scale_down {
        stabilization_window_seconds = 300
        select_policy               = "Min"
        
        policy {
          type          = "Percent"
          value         = 10
          period_seconds = 60
        }
      }
    }
  }
}

# Pod Disruption Budget
resource "kubernetes_pod_disruption_budget_v1" "product_catalog_pdb" {
  metadata {
    name      = "product-catalog-pdb"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }
  
  spec {
    min_available = 2
    
    selector {
      match_labels = {
        app = "product-catalog"
      }
    }
  }
}

# Network Policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_ingress" {
  metadata {
    name      = "allow-from-ingress"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/part-of" = "ecommerce"
      }
    }
    
    policy_types = ["Ingress"]
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.ingress.metadata[0].name
          }
        }
      }
    }
  }
}

# Apply Kubernetes manifests using kubectl after cluster is ready
resource "null_resource" "apply_manifests" {
  depends_on = [
    azurerm_kubernetes_cluster.main,
    helm_release.nginx_ingress,
    helm_release.cert_manager,
    helm_release.prometheus_stack
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
  namespace: ${kubernetes_namespace.apps.metadata[0].name}
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
  namespace: ${kubernetes_namespace.apps.metadata[0].name}
  labels:
    release: ${helm_release.prometheus_stack.name}
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


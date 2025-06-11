# E-Commerce Platform Monitoring Setup Script for Azure AKS
# This script sets up Prometheus and Grafana monitoring for the e-commerce platform on Azure AKS

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🔍 Setting up Monitoring Stack for E-Commerce Platform on Azure AKS${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Check if kubectl is configured for AKS cluster
try {
    kubectl cluster-info | Out-Null
    Write-Host "${Green}✅ kubectl is configured${Reset}"
}
catch {
    Write-Host "${Red}❌ kubectl is not configured or AKS cluster is not accessible.${Reset}"
    Write-Host "${Yellow}Please ensure you're connected to your AKS cluster:${Reset}"
    Write-Host "${Yellow}az aks get-credentials --resource-group <resource-group> --name <cluster-name>${Reset}"
    exit 1
}

# Verify we're connected to an AKS cluster
$clusterInfo = kubectl cluster-info 2>$null | Select-Object -First 1
if ($clusterInfo -notlike "*azmk8s.io*") {
    Write-Host "${Yellow}⚠️  Warning: You don't appear to be connected to an Azure AKS cluster.${Reset}"
    Write-Host "${Yellow}Current cluster: $clusterInfo${Reset}"
    $response = Read-Host "Do you want to continue anyway? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        exit 1
    }
}

# Check if Helm is installed
try {
    helm version --short | Out-Null
    Write-Host "${Green}✅ Helm is installed${Reset}"
}
catch {
    Write-Host "${Red}❌ Helm is not installed. Please install Helm first.${Reset}"
    Write-Host "${Yellow}Visit: https://helm.sh/docs/intro/install/${Reset}"
    exit 1
}

# Create monitoring namespace
Write-Host "${Blue}📁 Creating monitoring namespace...${Reset}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
Write-Host "${Blue}📦 Adding Helm repositories...${Reset}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus Stack (includes Prometheus, Grafana, AlertManager, Node Exporter)
Write-Host "${Blue}🔍 Installing Prometheus Stack for Azure AKS...${Reset}"
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false `
  --set prometheus.prometheusSpec.retention=30d `
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=managed-premium `
  --set "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce" `
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi `
  --set grafana.adminPassword=admin123 `
  --set grafana.persistence.enabled=true `
  --set grafana.persistence.storageClassName=managed-premium `
  --set grafana.persistence.size=10Gi `
  --set grafana.ingress.enabled=true `
  --set grafana.ingress.ingressClassName=nginx `
  --set "grafana.ingress.hosts[0]=grafana.ecommerce.azure.local" `
  --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Prometheus Stack installation failed!${Reset}"
    exit 1
}

# Wait for Prometheus Stack to be ready
Write-Host "${Yellow}⏳ Waiting for Prometheus Stack to be ready...${Reset}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Install Redis Exporter for Redis monitoring (if Redis is deployed)
Write-Host "${Blue}📊 Installing Redis Exporter...${Reset}"
try {
    helm upgrade --install redis-exporter prometheus-community/prometheus-redis-exporter `
      --namespace ecommerce `
      --set redisAddress=redis://ecommerce-app-redis-master:6379 `
      --set serviceMonitor.enabled=true `
      --set serviceMonitor.namespace=monitoring `
      --wait
} catch {
    Write-Host "${Yellow}⚠️  Redis Exporter installation failed (Redis may not be deployed yet)${Reset}"
}

# Create ServiceMonitor for E-Commerce applications
Write-Host "${Blue}📈 Creating ServiceMonitor for E-Commerce applications...${Reset}"
$serviceMonitorYaml = @"
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ecommerce-apps
  namespace: monitoring
  labels:
    release: prometheus-stack
spec:
  namespaceSelector:
    matchNames:
    - ecommerce
  selector:
    matchLabels:
      app.kubernetes.io/part-of: ecommerce
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
"@

$serviceMonitorYaml | kubectl apply -f -

# Create Grafana dashboards ConfigMap
Write-Host "${Blue}📊 Creating Grafana dashboards...${Reset}"
$dashboardConfigMap = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-dashboards
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  ecommerce-overview.json: |
    {
      "dashboard": {
        "id": null,
        "title": "E-Commerce Platform Overview",
        "tags": ["ecommerce"],
        "style": "dark",
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "Frontend Requests",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total{job=\"ecommerce-frontend\"}[5m])",
                "legendFormat": "{{method}} {{status_code}}"
              }
            ]
          },
          {
            "id": 2,
            "title": "Backend API Requests",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total{job=\"ecommerce-backend\"}[5m])",
                "legendFormat": "{{method}} {{endpoint}}"
              }
            ]
          }
        ],
        "time": {
          "from": "now-1h",
          "to": "now"
        },
        "refresh": "30s"
      }
    }
"@

$dashboardConfigMap | kubectl apply -f -

Write-Host "${Green}✅ Monitoring stack installation completed!${Reset}"
Write-Host ""
Write-Host "${Cyan}📋 Monitoring Information:${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Get LoadBalancer IP for ingress
try {
    $nginxIP = kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    if (-not $nginxIP) { $nginxIP = "Pending..." }
} catch {
    $nginxIP = "Pending..."
}

Write-Host "${Yellow}📊 Grafana:${Reset}"
if ($nginxIP -ne "Pending...") {
    Write-Host "  URL: http://grafana.ecommerce.azure.local (Add to hosts: $nginxIP grafana.ecommerce.azure.local)"
} else {
    Write-Host "  URL: http://grafana.ecommerce.azure.local (LoadBalancer IP pending)"
}
Write-Host "  Username: admin"
Write-Host "  Password: admin123"
Write-Host "  Port Forward: kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80"
Write-Host ""

Write-Host "${Yellow}🔍 Prometheus:${Reset}"
Write-Host "  Port Forward: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
Write-Host "  URL: http://localhost:9090"
Write-Host ""

Write-Host "${Yellow}🚨 AlertManager:${Reset}"
Write-Host "  Port Forward: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093"
Write-Host "  URL: http://localhost:9093"
Write-Host ""

Write-Host "${Yellow}🔧 Useful Commands:${Reset}"
Write-Host "  Check monitoring pods: ${Cyan}kubectl get pods -n monitoring${Reset}"
Write-Host "  View Grafana logs: ${Cyan}kubectl logs -n monitoring -l app.kubernetes.io/name=grafana${Reset}"
Write-Host "  View Prometheus logs: ${Cyan}kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus${Reset}"
Write-Host "  Port forward Grafana: ${Cyan}kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80${Reset}"
Write-Host ""

if ($nginxIP -ne "Pending...") {
    Write-Host "${Green}🎉 Add this entry to your hosts file (C:\Windows\System32\drivers\etc\hosts):${Reset}"
    Write-Host "${Cyan}$nginxIP grafana.ecommerce.azure.local${Reset}"
} else {
    Write-Host "${Yellow}⏳ LoadBalancer IP is still pending. Run this command to get it later:${Reset}"
    Write-Host "${Cyan}kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx${Reset}"
}

Write-Host ""
Write-Host "${Green}✅ Monitoring is now ready! Visit Grafana to view your dashboards.${Reset}"

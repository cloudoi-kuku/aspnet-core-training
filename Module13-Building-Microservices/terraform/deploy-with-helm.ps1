# E-Commerce Microservices Deployment Script for Azure AKS
# This script deploys the complete e-commerce platform using Helm charts instead of Terraform

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🚀 Deploying E-Commerce Microservices Platform to Azure AKS${Reset}"
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

Write-Host "${Green}✅ Prerequisites check passed${Reset}"
Write-Host ""

# Step 1: Create namespaces
Write-Host "${Blue}📁 Creating namespaces...${Reset}"
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Add Helm repositories
Write-Host "${Blue}📦 Adding Helm repositories...${Reset}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Step 3: Install NGINX Ingress Controller
Write-Host "${Blue}🌐 Installing NGINX Ingress Controller...${Reset}"
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx `
  --namespace ingress-nginx `
  --set controller.service.type=LoadBalancer `
  --set "controller.service.annotations.service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path=/healthz" `
  --set controller.metrics.enabled=true `
  --set controller.metrics.serviceMonitor.enabled=true `
  --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ NGINX Ingress installation failed!${Reset}"
    exit 1
}

# Step 4: Install Cert-Manager for TLS
Write-Host "${Blue}🔒 Installing Cert-Manager...${Reset}"
helm upgrade --install cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --version v1.13.2 `
  --set installCRDs=true `
  --set prometheus.enabled=true `
  --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Cert-Manager installation failed!${Reset}"
    exit 1
}

# Step 5: Install Prometheus Stack
Write-Host "${Blue}📊 Installing Prometheus Stack...${Reset}"
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

# Step 6: Deploy E-Commerce Application
Write-Host "${Blue}🛒 Deploying E-Commerce Application...${Reset}"
helm upgrade --install ecommerce-app .\helm-charts\ecommerce-app `
  --namespace ecommerce `
  --values .\helm-charts\azure-values.yaml `
  --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ E-Commerce application deployment failed!${Reset}"
    exit 1
}

# Step 7: Create ClusterIssuer for Let's Encrypt
Write-Host "${Blue}🔐 Creating ClusterIssuer for Let's Encrypt...${Reset}"
$clusterIssuerYaml = @"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@ecommerce.azure.local
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
"@

$clusterIssuerYaml | kubectl apply -f -

# Step 8: Wait for deployments to be ready
Write-Host "${Yellow}⏳ Waiting for all deployments to be ready...${Reset}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Wait for e-commerce app pods (with error handling)
try {
    kubectl wait --for=condition=ready pod -l app=ecommerce-app-frontend -n ecommerce --timeout=300s
} catch {
    Write-Host "${Yellow}⚠️  Frontend pods may still be starting...${Reset}"
}

try {
    kubectl wait --for=condition=ready pod -l app=ecommerce-app-backend -n ecommerce --timeout=300s
} catch {
    Write-Host "${Yellow}⚠️  Backend pods may still be starting...${Reset}"
}

# Step 9: Get service information
Write-Host "${Green}✅ Deployment completed successfully!${Reset}"
Write-Host ""
Write-Host "${Cyan}📋 Service Information:${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Get LoadBalancer IP
try {
    $nginxIP = kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    if (-not $nginxIP) { $nginxIP = "Pending..." }
} catch {
    $nginxIP = "Pending..."
}

Write-Host "${Yellow}🌐 NGINX Ingress Controller:${Reset}"
Write-Host "  External IP: ${Green}$nginxIP${Reset}"
if ($nginxIP -ne "Pending...") {
    Write-Host "  Status: ${Green}Ready${Reset}"
} else {
    Write-Host "  Status: ${Yellow}Pending${Reset}"
}
Write-Host ""

Write-Host "${Yellow}🛒 E-Commerce Application:${Reset}"
Write-Host "  Frontend: http://ecommerce.azure.local (Add to hosts: $nginxIP ecommerce.azure.local)"
Write-Host "  Backend API: http://api.ecommerce.azure.local (Add to hosts: $nginxIP api.ecommerce.azure.local)"
Write-Host ""

Write-Host "${Yellow}📊 Monitoring:${Reset}"
Write-Host "  Grafana: http://grafana.ecommerce.azure.local (Add to hosts: $nginxIP grafana.ecommerce.azure.local)"
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
Write-Host "  Check all pods: ${Cyan}kubectl get pods --all-namespaces${Reset}"
Write-Host "  Check ingress: ${Cyan}kubectl get ingress --all-namespaces${Reset}"
Write-Host "  View logs: ${Cyan}kubectl logs -n ecommerce -l app=ecommerce-app-frontend${Reset}"
Write-Host "  Scale frontend: ${Cyan}kubectl scale deployment ecommerce-app-frontend -n ecommerce --replicas=3${Reset}"
Write-Host ""

if ($nginxIP -ne "Pending...") {
    Write-Host "${Green}🎉 Add these entries to your hosts file (C:\Windows\System32\drivers\etc\hosts):${Reset}"
    Write-Host "${Cyan}$nginxIP ecommerce.azure.local${Reset}"
    Write-Host "${Cyan}$nginxIP api.ecommerce.azure.local${Reset}"
    Write-Host "${Cyan}$nginxIP grafana.ecommerce.azure.local${Reset}"
} else {
    Write-Host "${Yellow}⏳ LoadBalancer IP is still pending. Run this command to get it later:${Reset}"
    Write-Host "${Cyan}kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx${Reset}"
}

Write-Host ""
Write-Host "${Green}✅ E-Commerce platform is now deployed and ready to use!${Reset}"

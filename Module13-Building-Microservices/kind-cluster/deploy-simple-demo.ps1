# Deploy Simple Microservices Demo
# This script deploys a simple 3-service microservices demo

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🚀 Deploying Simple Microservices Demo${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Check if kubectl is available
try {
    kubectl cluster-info | Out-Null
    Write-Host "${Green}✅ Connected to Kubernetes cluster${Reset}"
} catch {
    Write-Host "${Red}❌ Not connected to Kubernetes cluster${Reset}"
    Write-Host "${Yellow}Please connect to a cluster first (Kind, AKS, etc.)${Reset}"
    exit 1
}

# Create namespace
Write-Host "${Blue}📁 Creating namespace...${Reset}"
kubectl create namespace microservices-demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy with Helm
Write-Host "${Blue}🎯 Deploying microservices...${Reset}"
helm upgrade --install simple-microservices ./simple-microservices `
  --namespace microservices-demo `
  --wait

if ($LASTEXITCODE -eq 0) {
    Write-Host "${Green}✅ Deployment successful!${Reset}"
} else {
    Write-Host "${Red}❌ Deployment failed${Reset}"
    exit 1
}

# Wait for pods to be ready
Write-Host "${Yellow}⏳ Waiting for pods to be ready...${Reset}"
kubectl wait --for=condition=ready pod --all -n microservices-demo --timeout=60s

# Show deployment status
Write-Host "${Blue}📋 Deployment Status:${Reset}"
kubectl get pods -n microservices-demo
Write-Host ""
kubectl get services -n microservices-demo

# Get ingress info
Write-Host ""
Write-Host "${Blue}🌐 Access Information:${Reset}"
$ingressIP = kubectl get ingress microservices-ingress -n microservices-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null

if ($ingressIP) {
    Write-Host "Add to hosts file: ${Green}$ingressIP microservices.local${Reset}"
    Write-Host "Then visit: ${Green}http://microservices.local${Reset}"
} else {
    Write-Host "Port forward to access: ${Cyan}kubectl port-forward -n microservices-demo svc/gateway 8080:80${Reset}"
    Write-Host "Then visit: ${Green}http://localhost:8080${Reset}"
}

Write-Host ""
Write-Host "${Cyan}🎯 Demo Features:${Reset}"
Write-Host "  • ${Green}Gateway Service${Reset} - Main entry point"
Write-Host "  • ${Green}Product Service${Reset} - Manages products"
Write-Host "  • ${Green}Order Service${Reset} - Handles orders"
Write-Host "  • ${Green}Payment Service${Reset} - Processes payments"

Write-Host ""
Write-Host "${Yellow}🔧 Try These Commands:${Reset}"
Write-Host "  View pods: ${Cyan}kubectl get pods -n microservices-demo${Reset}"
Write-Host "  Scale service: ${Cyan}kubectl scale deployment product-service -n microservices-demo --replicas=3${Reset}"
Write-Host "  View logs: ${Cyan}kubectl logs -n microservices-demo -l app=product-service${Reset}"
Write-Host "  Delete demo: ${Cyan}helm uninstall simple-microservices -n microservices-demo${Reset}"

Write-Host ""
Write-Host "${Green}🎉 Simple Microservices Demo is ready!${Reset}"

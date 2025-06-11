# E-Commerce Platform Cleanup Script for Azure AKS
# This script removes all Helm deployments and optionally destroys Azure infrastructure

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🧹 E-Commerce Platform Cleanup Script${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Check if kubectl is configured
try {
    kubectl cluster-info | Out-Null
    Write-Host "${Green}✅ kubectl is configured${Reset}"
}
catch {
    Write-Host "${Red}❌ kubectl is not configured or cluster is not accessible.${Reset}"
    Write-Host "${Yellow}Please ensure you're connected to your cluster.${Reset}"
    exit 1
}

Write-Host "${Yellow}⚠️  This will remove all deployed applications and monitoring.${Reset}"
$response = Read-Host "Are you sure you want to continue? (y/N)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "${Blue}Cleanup cancelled.${Reset}"
    exit 0
}

# Step 1: Remove Helm releases
Write-Host "${Blue}📦 Removing Helm releases...${Reset}"

# Remove e-commerce application
$ecommerceApp = helm list -n ecommerce -q | Select-String "ecommerce-app"
if ($ecommerceApp) {
    Write-Host "${Yellow}Removing e-commerce application...${Reset}"
    helm uninstall ecommerce-app -n ecommerce
} else {
    Write-Host "${Yellow}E-commerce application not found, skipping...${Reset}"
}

# Remove Prometheus stack
$prometheusStack = helm list -n monitoring -q | Select-String "prometheus-stack"
if ($prometheusStack) {
    Write-Host "${Yellow}Removing Prometheus stack...${Reset}"
    helm uninstall prometheus-stack -n monitoring
} else {
    Write-Host "${Yellow}Prometheus stack not found, skipping...${Reset}"
}

# Remove NGINX Ingress
$nginxIngress = helm list -n ingress-nginx -q | Select-String "nginx-ingress"
if ($nginxIngress) {
    Write-Host "${Yellow}Removing NGINX Ingress Controller...${Reset}"
    helm uninstall nginx-ingress -n ingress-nginx
} else {
    Write-Host "${Yellow}NGINX Ingress not found, skipping...${Reset}"
}

# Remove Cert-Manager
$certManager = helm list -n cert-manager -q | Select-String "cert-manager"
if ($certManager) {
    Write-Host "${Yellow}Removing Cert-Manager...${Reset}"
    helm uninstall cert-manager -n cert-manager
} else {
    Write-Host "${Yellow}Cert-Manager not found, skipping...${Reset}"
}

# Step 2: Remove custom resources
Write-Host "${Blue}🗑️  Removing custom resources...${Reset}"

# Remove ClusterIssuer
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found=true

# Remove ServiceMonitors
kubectl delete servicemonitor --all -n ecommerce --ignore-not-found=true
kubectl delete servicemonitor --all -n monitoring --ignore-not-found=true

# Remove SecretProviderClass
kubectl delete secretproviderclass azure-keyvault-secrets -n ecommerce --ignore-not-found=true

# Step 3: Remove persistent volumes and claims
Write-Host "${Blue}💾 Removing persistent volumes...${Reset}"
kubectl delete pvc --all -n ecommerce --ignore-not-found=true
kubectl delete pvc --all -n monitoring --ignore-not-found=true

# Step 4: Remove namespaces
Write-Host "${Blue}📁 Removing namespaces...${Reset}"
kubectl delete namespace ecommerce --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true
kubectl delete namespace ingress-nginx --ignore-not-found=true
kubectl delete namespace cert-manager --ignore-not-found=true

# Wait for namespaces to be fully deleted
Write-Host "${Yellow}⏳ Waiting for namespaces to be fully deleted...${Reset}"
$namespaces = @("ecommerce", "monitoring", "ingress-nginx", "cert-manager")
foreach ($ns in $namespaces) {
    do {
        $exists = kubectl get namespace $ns 2>$null
        if ($exists) {
            Write-Host "${Yellow}Waiting for namespace $ns to be deleted...${Reset}"
            Start-Sleep -Seconds 5
        }
    } while ($exists)
}

Write-Host "${Green}✅ All Helm releases and Kubernetes resources have been removed.${Reset}"

# Step 5: Ask about Azure infrastructure
Write-Host ""
Write-Host "${Yellow}🏗️  Azure Infrastructure:${Reset}"
Write-Host "${Yellow}Do you want to destroy the Azure infrastructure (AKS cluster, etc.) as well?${Reset}"
$response = Read-Host "This will run 'terraform destroy' (y/N)"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "${Blue}🏗️  Destroying Azure infrastructure with Terraform...${Reset}"
    
    if (Test-Path "terraform.tfstate") {
        terraform destroy -auto-approve
        if ($LASTEXITCODE -eq 0) {
            Write-Host "${Green}✅ Azure infrastructure destroyed successfully.${Reset}"
        } else {
            Write-Host "${Red}❌ Failed to destroy Azure infrastructure. Check Terraform logs.${Reset}"
        }
    } else {
        Write-Host "${Red}❌ No Terraform state file found. Infrastructure may need to be cleaned up manually.${Reset}"
    }
} else {
    Write-Host "${Blue}Azure infrastructure preserved. You can destroy it later with:${Reset}"
    Write-Host "${Cyan}terraform destroy${Reset}"
}

Write-Host ""
Write-Host "${Green}🎉 Cleanup completed!${Reset}"
Write-Host ""
Write-Host "${Yellow}📋 Summary:${Reset}"
Write-Host "  ✅ Helm releases removed"
Write-Host "  ✅ Kubernetes resources deleted"
Write-Host "  ✅ Persistent volumes cleaned up"
Write-Host "  ✅ Namespaces removed"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "  ✅ Azure infrastructure destroyed"
} else {
    Write-Host "  ⏸️  Azure infrastructure preserved"
}

Write-Host ""
Write-Host "${Cyan}To redeploy the platform, run:${Reset}"
Write-Host "${Cyan}.\deploy-with-helm.ps1${Reset}"

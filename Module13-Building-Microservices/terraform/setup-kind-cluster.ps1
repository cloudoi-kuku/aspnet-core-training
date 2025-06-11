# Kind Cluster Setup and Troubleshooting Script
# This script creates a Kind cluster with proper error handling and troubleshooting

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🚀 Setting up Kind Cluster for E-Commerce Platform${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Check prerequisites
Write-Host "${Blue}🔍 Checking prerequisites...${Reset}"

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "${Green}✅ Docker: $dockerVersion${Reset}"
    
    docker info | Out-Null
    Write-Host "${Green}✅ Docker is running${Reset}"
} catch {
    Write-Host "${Red}❌ Docker is not installed or not running${Reset}"
    Write-Host "${Yellow}Please install Docker Desktop and ensure it's running${Reset}"
    exit 1
}

# Check Kind
try {
    $kindVersion = kind version
    Write-Host "${Green}✅ Kind: $kindVersion${Reset}"
} catch {
    Write-Host "${Red}❌ Kind is not installed${Reset}"
    Write-Host "${Yellow}Install Kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation${Reset}"
    exit 1
}

# Check kubectl
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    Write-Host "${Green}✅ kubectl: $kubectlVersion${Reset}"
} catch {
    Write-Host "${Red}❌ kubectl is not installed${Reset}"
    Write-Host "${Yellow}Install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/${Reset}"
    exit 1
}

# Check Docker resources
Write-Host "${Blue}📊 Checking Docker resources...${Reset}"
$dockerInfo = docker system info --format "{{.MemTotal}}" 2>$null
if ($dockerInfo) {
    Write-Host "${Green}✅ Docker has sufficient resources${Reset}"
} else {
    Write-Host "${Yellow}⚠️  Could not check Docker resources${Reset}"
}

# Clean up any existing cluster
Write-Host "${Blue}🧹 Cleaning up existing resources...${Reset}"
$existingCluster = kind get clusters 2>$null | Select-String "ecommerce"
if ($existingCluster) {
    Write-Host "${Yellow}Deleting existing ecommerce cluster...${Reset}"
    kind delete cluster --name ecommerce
}

# Clean up Docker resources
Write-Host "${Yellow}Cleaning up Docker resources...${Reset}"
docker system prune -f | Out-Null

# Create cluster with simple configuration first
Write-Host "${Blue}🏗️  Creating Kind cluster (simple configuration)...${Reset}"
$clusterCreated = $false

try {
    kind create cluster --config kind-cluster-simple.yaml --wait 300s
    $clusterCreated = $true
    Write-Host "${Green}✅ Kind cluster created successfully!${Reset}"
} catch {
    Write-Host "${Red}❌ Failed to create cluster with simple config${Reset}"
    Write-Host "${Yellow}Trying with minimal configuration...${Reset}"
    
    # Try with absolute minimal config
    $minimalConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ecommerce
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
  - containerPort: 443
    hostPort: 443
"@
    
    $minimalConfig | Out-File -FilePath "kind-minimal.yaml" -Encoding UTF8
    
    try {
        kind create cluster --config kind-minimal.yaml --wait 300s
        $clusterCreated = $true
        Write-Host "${Green}✅ Kind cluster created with minimal configuration!${Reset}"
    } catch {
        Write-Host "${Red}❌ Failed to create cluster even with minimal config${Reset}"
        Write-Host "${Yellow}Troubleshooting information:${Reset}"
        
        # Show Docker info
        Write-Host "${Blue}Docker system info:${Reset}"
        docker system info | Select-String -Pattern "(CPUs|Total Memory|Docker Root Dir)"
        
        # Show Docker disk usage
        Write-Host "${Blue}Docker disk usage:${Reset}"
        docker system df
        
        Write-Host "${Red}Please try the following:${Reset}"
        Write-Host "1. Restart Docker Desktop"
        Write-Host "2. Increase Docker memory allocation (4GB+ recommended)"
        Write-Host "3. Free up disk space"
        Write-Host "4. Try: docker system prune -a -f"
        
        exit 1
    }
}

if ($clusterCreated) {
    # Verify cluster is working
    Write-Host "${Blue}🔍 Verifying cluster...${Reset}"
    
    # Wait for cluster to be ready
    Write-Host "${Yellow}Waiting for cluster to be ready...${Reset}"
    $timeout = 120
    $elapsed = 0
    do {
        try {
            kubectl get nodes | Out-Null
            $ready = $true
            break
        } catch {
            Start-Sleep -Seconds 5
            $elapsed += 5
            Write-Host "${Yellow}Still waiting... ($elapsed/$timeout seconds)${Reset}"
        }
    } while ($elapsed -lt $timeout)
    
    if ($ready) {
        Write-Host "${Green}✅ Cluster is ready!${Reset}"
        
        # Show cluster info
        Write-Host "${Blue}📋 Cluster Information:${Reset}"
        kubectl cluster-info
        
        Write-Host "${Blue}📋 Node Information:${Reset}"
        kubectl get nodes -o wide
        
        # Install NGINX Ingress Controller
        Write-Host "${Blue}🌐 Installing NGINX Ingress Controller...${Reset}"
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        
        # Wait for ingress controller to be ready
        Write-Host "${Yellow}Waiting for ingress controller...${Reset}"
        kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
        
        Write-Host "${Green}✅ NGINX Ingress Controller installed!${Reset}"
        
        Write-Host ""
        Write-Host "${Cyan}🎉 Kind cluster is ready for deployment!${Reset}"
        Write-Host ""
        Write-Host "${Yellow}Next steps:${Reset}"
        Write-Host "1. Deploy applications: ${Cyan}.\deploy-with-helm.ps1${Reset}"
        Write-Host "2. Check cluster: ${Cyan}kubectl get all --all-namespaces${Reset}"
        Write-Host "3. Access services via: ${Cyan}http://localhost${Reset}"
        
    } else {
        Write-Host "${Red}❌ Cluster failed to become ready within timeout${Reset}"
        Write-Host "${Yellow}Try: kubectl get pods --all-namespaces${Reset}"
        exit 1
    }
} else {
    Write-Host "${Red}❌ Failed to create Kind cluster${Reset}"
    exit 1
}

# Clean up temporary files
if (Test-Path "kind-minimal.yaml") {
    Remove-Item "kind-minimal.yaml"
}

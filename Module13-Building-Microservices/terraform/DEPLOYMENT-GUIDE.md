# E-Commerce Microservices Deployment Guide for Azure AKS

This guide explains how to deploy the comprehensive e-commerce platform to Azure AKS using the integrated Helm charts from the FinalProject-FullStack-ECommerce.

## Overview

The deployment has been restructured to use Helm charts directly instead of Terraform's Helm provider for better flexibility and control. The platform includes:

- **Frontend**: Next.js React application (Port 3000)
- **Backend**: .NET 8 API (Port 7000, Metrics 7001)
- **Database**: SQLite with persistent storage
- **Message Queue**: Redis (6379) and RabbitMQ (5672)
- **Monitoring**: Prometheus and Grafana
- **Ingress**: NGINX Ingress Controller
- **TLS**: Cert-Manager with Let's Encrypt

## Port Configuration

All internal and external ports are configured to be consistent to avoid deployment issues:

| Service | Internal Port | External Port | Metrics Port | Purpose |
|---------|---------------|---------------|--------------|---------|
| Frontend | 3000 | 3000 | 3000 | Next.js SSR App + Metrics |
| Backend | 7000 | 7000 | 7001 | .NET API + Separate Metrics |
| Redis | 6379 | 6379 | - | Cache & Session Store |
| RabbitMQ | 5672 | 5672 | - | Message Queue |
| Prometheus | 9090 | 9090 | - | Metrics Collection |
| Grafana | 3000 | 80 | - | Monitoring Dashboard |

## Prerequisites

1. **Azure CLI** installed and configured
2. **kubectl** installed
3. **Helm 3.x** installed
4. **Terraform** (for infrastructure provisioning)
5. **Azure subscription** with appropriate permissions

## Deployment Steps

### Step 1: Navigate to Terraform Directory

All deployment operations should be performed from the terraform directory:

```powershell
cd Module13-Building-Microservices/terraform
```

### Step 2: Provision Azure Infrastructure

Provision the AKS cluster and supporting Azure resources using Terraform:

```powershell
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

This creates:
- Azure Resource Group
- AKS Cluster with auto-scaling node pools
- Azure Key Vault
- Application Insights
- SQL Server (for enterprise scenarios)
- Service Bus
- Virtual Network and subnets

### Step 3: Connect to AKS Cluster

Get credentials for your AKS cluster:

```powershell
az aks get-credentials --resource-group ecommerce-microservices-rg --name ecommerce-aks-cluster
```

Verify connection:

```powershell
kubectl cluster-info
kubectl get nodes
```

### Step 4: Deploy Applications with Helm

Use the comprehensive deployment script:

```powershell
# Run the deployment script
.\deploy-with-helm.ps1
```

This script will:
1. Create necessary namespaces
2. Add required Helm repositories
3. Install NGINX Ingress Controller
4. Install Cert-Manager for TLS
5. Install Prometheus monitoring stack
6. Deploy the e-commerce application
7. Configure Let's Encrypt ClusterIssuer
8. Wait for all deployments to be ready

### Step 5: Configure DNS (Local Development)

Add these entries to your `C:\Windows\System32\drivers\etc\hosts` file (replace `<EXTERNAL-IP>` with the LoadBalancer IP):

```
<EXTERNAL-IP> ecommerce.azure.local
<EXTERNAL-IP> api.ecommerce.azure.local
<EXTERNAL-IP> grafana.ecommerce.azure.local
```

Get the external IP:

```powershell
kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx
```

## Application Access

### E-Commerce Platform
- **Frontend**: http://ecommerce.azure.local
- **Backend API**: http://api.ecommerce.azure.local
- **API Documentation**: http://api.ecommerce.azure.local/swagger

### Monitoring
- **Grafana**: http://grafana.ecommerce.azure.local
  - Username: `admin`
  - Password: `admin123`
- **Prometheus**: Port-forward to access
  ```bash
  kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
  ```

## Helm Charts Structure

The integrated Helm charts are located in `helm-charts/ecommerce-app/` and include:

```
helm-charts/ecommerce-app/
├── Chart.yaml                    # Chart metadata and dependencies
├── values.yaml                   # Default configuration values
└── templates/
    ├── _helpers.tpl              # Template helpers
    ├── backend-deployment.yaml   # .NET API deployment
    ├── backend-service.yaml      # Backend service
    ├── frontend-deployment.yaml  # Next.js frontend deployment
    ├── frontend-service.yaml     # Frontend service
    ├── configmap.yaml           # Application configuration
    ├── secret.yaml              # Application secrets
    ├── ingress.yaml             # Ingress configuration
    ├── pvc.yaml                 # Persistent volume claims
    ├── servicemonitor.yaml      # Prometheus monitoring
    └── grafana-dashboard-configmap.yaml  # Grafana dashboards
```

## Azure-Specific Configurations

The Helm values have been configured for Azure AKS:

- **Storage Class**: `managed-premium` for persistent volumes
- **Ingress**: NGINX with Azure LoadBalancer
- **TLS**: Cert-Manager with Let's Encrypt
- **Monitoring**: Prometheus with Azure-optimized storage
- **Autoscaling**: HPA configured for Azure node pools

## Monitoring and Observability

### Prometheus Metrics
The platform exposes metrics for:
- Application performance (.NET and Next.js)
- Infrastructure metrics (nodes, pods, containers)
- Custom business metrics

### Grafana Dashboards
Pre-configured dashboards for:
- Kubernetes cluster overview
- .NET application metrics
- Node.js/Next.js metrics
- Infrastructure monitoring

### Alerts
AlertManager is configured with rules for:
- High CPU/Memory usage
- Pod restart loops
- Service availability
- Custom application alerts

## Scaling and Performance

### Horizontal Pod Autoscaling (HPA)
- **Frontend**: 2-10 replicas based on CPU (70%)
- **Backend**: 3-15 replicas based on CPU (70%)

### Cluster Autoscaling
- **System pool**: 2-5 nodes (Standard_D2s_v3)
- **User pool**: 1-3 nodes (Standard_D2s_v3)

## Troubleshooting

### Common Issues

1. **LoadBalancer IP Pending**
   ```bash
   kubectl get svc -n ingress-nginx
   # Wait for Azure to provision the LoadBalancer
   ```

2. **Pods Not Starting**
   ```bash
   kubectl get pods --all-namespaces
   kubectl describe pod <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace>
   ```

3. **Ingress Not Working**
   ```bash
   kubectl get ingress --all-namespaces
   kubectl describe ingress <ingress-name> -n <namespace>
   ```

### Useful Commands

```powershell
# Check all resources
kubectl get all --all-namespaces

# View logs
kubectl logs -n ecommerce -l app=ecommerce-app-frontend
kubectl logs -n ecommerce -l app=ecommerce-app-backend

# Scale applications
kubectl scale deployment ecommerce-app-frontend -n ecommerce --replicas=5
kubectl scale deployment ecommerce-app-backend -n ecommerce --replicas=8

# Port forward for local access
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80
kubectl port-forward -n ecommerce svc/ecommerce-app-frontend 3000:3000
kubectl port-forward -n ecommerce svc/ecommerce-app-backend 7000:7000
```

## Cleanup

To remove the entire deployment:

```powershell
# Use the cleanup script
.\cleanup.ps1

# Or manually delete Helm releases
helm uninstall ecommerce-app -n ecommerce
helm uninstall prometheus-stack -n monitoring
helm uninstall nginx-ingress -n ingress-nginx
helm uninstall cert-manager -n cert-manager

# Delete namespaces
kubectl delete namespace ecommerce monitoring ingress-nginx cert-manager

# Destroy Azure infrastructure
terraform destroy
```

## Security Considerations

- All secrets are managed through Kubernetes secrets
- Network policies restrict inter-pod communication
- RBAC is enabled on the AKS cluster
- TLS encryption for all external traffic
- Azure Key Vault integration for sensitive data

## PowerShell Scripts Overview

The project includes comprehensive PowerShell scripts for Windows users:

### Main Scripts
- **`setup-module13.ps1`** - Complete project setup and local testing
- **`build-images.ps1`** - Build Docker images for frontend and backend
- **`terraform\deploy-with-helm.ps1`** - Deploy to Azure AKS using Helm
- **`terraform\setup-monitoring.ps1`** - Setup monitoring stack only
- **`terraform\cleanup.ps1`** - Clean up all deployments

### Usage Examples

```powershell
# Complete setup and local testing
.\setup-module13.ps1

# Build Docker images with custom registry
.\build-images.ps1 -Registry "myregistry.azurecr.io" -Tag "v1.0.0"

# Deploy to Azure AKS
cd terraform
.\deploy-with-helm.ps1

# Setup monitoring only
.\setup-monitoring.ps1

# Clean up everything
.\cleanup.ps1
```

## Next Steps

1. Configure custom domain names
2. Set up CI/CD pipelines
3. Implement backup strategies
4. Configure log aggregation
5. Set up alerting notifications

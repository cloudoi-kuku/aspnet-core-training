# Manual Fix for Terraform State Issue

## 🔍 **Root Cause:**
Terraform state file contains Kubernetes resources that were created in previous runs, but now the Kubernetes provider is commented out. Terraform still tries to manage these resources during plan/apply.

## 🛠️ **Solution Options:**

### **Option 1: Use Terraform CLI (Recommended)**
If you have Terraform installed:

```bash
cd Module13-Building-Microservices/terraform

# Remove all Kubernetes resources from state
terraform state rm kubernetes_namespace.apps
terraform state rm kubernetes_namespace.ingress  
terraform state rm kubernetes_namespace.monitoring
terraform state rm kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa
terraform state rm kubernetes_network_policy.allow_ingress
terraform state rm kubernetes_network_policy.default_deny
terraform state rm kubernetes_pod_disruption_budget_v1.product_catalog_pdb

# Verify the fix
terraform plan
```

### **Option 2: Fresh Start (Nuclear Option)**
If Option 1 doesn't work:

```bash
cd Module13-Building-Microservices/terraform

# Backup current state
cp terraform.tfstate terraform.tfstate.backup-full

# Remove state files to start fresh
rm terraform.tfstate terraform.tfstate.backup

# Reinitialize and import existing resources
terraform init
terraform import azurerm_resource_group.main /subscriptions/6ef4cfbf-ca8b-4dec-a933-1c01a35638d5/resourceGroups/bisiecommerce-microservices-rg
terraform import azurerm_kubernetes_cluster.main /subscriptions/6ef4cfbf-ca8b-4dec-a933-1c01a35638d5/resourceGroups/bisiecommerce-microservices-rg/providers/Microsoft.ContainerService/managedClusters/ecommerce-aks

# Then run plan/apply
terraform plan
terraform apply
```

### **Option 3: Skip State Management**
Deploy applications directly without fixing Terraform:

```bash
# Get AKS credentials
az aks get-credentials --resource-group bisiecommerce-microservices-rg --name ecommerce-aks --admin

# Verify cluster works
kubectl get nodes

# Deploy applications directly
kubectl create namespace ecommerce-apps
kubectl create namespace ingress-nginx
kubectl create namespace monitoring

# Deploy NGINX Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx

# Deploy your applications
helm install ecommerce-app ./helm-charts/ecommerce-app --namespace ecommerce-apps
```

## 🎯 **Recommended Approach:**

1. **Try Option 1 first** (cleanest solution)
2. **If that fails, use Option 3** (skip Terraform for K8s resources)
3. **Option 2 as last resort** (requires re-importing everything)

## ✅ **Your Infrastructure is Already Working:**
- AKS Cluster: `ecommerce-aks` ✅
- SQL Server: `ecommerce-sqlserver-dr19r8.database.windows.net` ✅  
- Container Registry: `ecommerceacr2ngb.azurecr.io` ✅
- All resources have proper Enablon tags ✅

The issue is just with Terraform state management, not the actual infrastructure!

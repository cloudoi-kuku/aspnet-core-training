# Fix Terraform State - Remove Kubernetes Resources

## 🔍 **Problem:**
Terraform state contains Kubernetes resources that can't be managed because the Kubernetes provider can't connect during infrastructure deployment.

## ✅ **Solution:**
Remove the Kubernetes resources from Terraform state so only Azure infrastructure is managed.

## 🛠️ **Steps to Fix:**

### **Option 1: Use the cleanup script (Recommended)**
```bash
# Make sure you're in the terraform directory
cd Module13-Building-Microservices/terraform

# Run the cleanup script
./cleanup-k8s-state.sh
```

### **Option 2: Manual cleanup**
If you have terraform available, run these commands:

```bash
# Remove Kubernetes resources from state
terraform state rm kubernetes_namespace.apps
terraform state rm kubernetes_namespace.ingress  
terraform state rm kubernetes_namespace.monitoring
terraform state rm kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa
terraform state rm kubernetes_network_policy.allow_ingress
terraform state rm kubernetes_network_policy.default_deny
terraform state rm kubernetes_pod_disruption_budget_v1.product_catalog_pdb
```

### **Option 3: Start with clean state (if needed)**
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup-full

# Remove state file to start fresh (ONLY if other options don't work)
rm terraform.tfstate terraform.tfstate.backup
```

## 🚀 **After Cleanup:**

1. **Verify the fix:**
   ```bash
   terraform plan
   ```

2. **Deploy infrastructure:**
   ```bash
   terraform apply
   ```

3. **Deploy applications with Helm:**
   ```bash
   # Get AKS credentials
   az aks get-credentials --resource-group bisiecommerce-microservices-rg --name ecommerce-aks --admin

   # Deploy applications
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
   ```

## 📋 **What's Already Working:**
- ✅ AKS Cluster (ecommerce-aks)
- ✅ SQL Server with databases
- ✅ Container Registry
- ✅ Key Vault with secrets
- ✅ Service Bus
- ✅ All resources have Enablon tags

## 🎯 **Next Steps:**
After fixing the state, you can deploy your microservices applications using Helm charts!

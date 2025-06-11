#!/bin/bash

echo "🧹 Creating clean Terraform state with only Azure resources..."

# Backup the current state
cp terraform.tfstate terraform.tfstate.backup-with-k8s-$(date +%Y%m%d-%H%M%S)

# Create a temporary clean state by importing only Azure resources
echo "📋 Removing Kubernetes provider from state..."

# Method 1: Try to remove Kubernetes resources if terraform is available
if command -v terraform &> /dev/null; then
    echo "✅ Terraform found - removing Kubernetes resources from state..."
    terraform state rm kubernetes_namespace.apps 2>/dev/null || echo "kubernetes_namespace.apps not in state"
    terraform state rm kubernetes_namespace.ingress 2>/dev/null || echo "kubernetes_namespace.ingress not in state"
    terraform state rm kubernetes_namespace.monitoring 2>/dev/null || echo "kubernetes_namespace.monitoring not in state"
    terraform state rm kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa 2>/dev/null || echo "kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa not in state"
    terraform state rm kubernetes_network_policy.allow_ingress 2>/dev/null || echo "kubernetes_network_policy.allow_ingress not in state"
    terraform state rm kubernetes_network_policy.default_deny 2>/dev/null || echo "kubernetes_network_policy.default_deny not in state"
    terraform state rm kubernetes_pod_disruption_budget_v1.product_catalog_pdb 2>/dev/null || echo "kubernetes_pod_disruption_budget_v1.product_catalog_pdb not in state"
    terraform state rm kubernetes_config_map.app_config 2>/dev/null || echo "kubernetes_config_map.app_config not in state"
    terraform state rm null_resource.apply_manifests 2>/dev/null || echo "null_resource.apply_manifests not in state"
    
    echo "✅ Kubernetes resources removed from state"
    echo "🚀 You can now run 'terraform plan' and 'terraform apply'"
else
    echo "❌ Terraform not found in PATH"
    echo "📝 Manual steps needed:"
    echo "1. Install Terraform or add it to PATH"
    echo "2. Run: terraform state rm kubernetes_namespace.apps"
    echo "3. Run: terraform state rm kubernetes_namespace.ingress"
    echo "4. Run: terraform state rm kubernetes_namespace.monitoring"
    echo "5. Run: terraform state rm kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa"
    echo "6. Run: terraform state rm kubernetes_network_policy.allow_ingress"
    echo "7. Run: terraform state rm kubernetes_network_policy.default_deny"
    echo "8. Run: terraform state rm kubernetes_pod_disruption_budget_v1.product_catalog_pdb"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Run: terraform plan"
echo "2. Run: terraform apply (should show no changes)"
echo "3. Deploy apps: az aks get-credentials --resource-group bisiecommerce-microservices-rg --name ecommerce-aks --admin"
echo "4. Deploy apps: helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace"

#!/bin/bash

# Script to remove Kubernetes resources from Terraform state
# Run this script to clean up the state before applying the infrastructure-only configuration

echo "🧹 Cleaning up Kubernetes resources from Terraform state..."

# First, let's see what Kubernetes resources are in the state
echo "📋 Current Kubernetes resources in state:"
terraform state list | grep kubernetes || echo "No Kubernetes resources found with 'terraform state list'"

echo ""
echo "🗑️ Removing Kubernetes resources from state..."

# Remove all possible Kubernetes resources from state
terraform state rm kubernetes_namespace.apps 2>/dev/null || echo "kubernetes_namespace.apps not found in state"
terraform state rm kubernetes_namespace.ingress 2>/dev/null || echo "kubernetes_namespace.ingress not found in state"
terraform state rm kubernetes_namespace.monitoring 2>/dev/null || echo "kubernetes_namespace.monitoring not found in state"
terraform state rm kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa 2>/dev/null || echo "kubernetes_horizontal_pod_autoscaler_v2.product_catalog_hpa not found in state"
terraform state rm kubernetes_network_policy.allow_ingress 2>/dev/null || echo "kubernetes_network_policy.allow_ingress not found in state"
terraform state rm kubernetes_network_policy.default_deny 2>/dev/null || echo "kubernetes_network_policy.default_deny not found in state"
terraform state rm kubernetes_pod_disruption_budget_v1.product_catalog_pdb 2>/dev/null || echo "kubernetes_pod_disruption_budget_v1.product_catalog_pdb not found in state"
terraform state rm kubernetes_config_map.app_config 2>/dev/null || echo "kubernetes_config_map.app_config not found in state"

# Also remove any null resources that might be causing issues
terraform state rm null_resource.apply_manifests 2>/dev/null || echo "null_resource.apply_manifests not found in state"

echo ""
echo "✅ Cleanup complete!"
echo "📋 Remaining resources in state:"
terraform state list | grep -E "(kubernetes|null_resource)" || echo "No Kubernetes or null resources remaining"

echo ""
echo "🚀 You can now run 'terraform plan' and 'terraform apply' to deploy infrastructure only"

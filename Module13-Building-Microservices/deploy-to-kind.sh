#!/bin/bash

set -e

echo "🚀 Deploying E-commerce Microservices to KIND cluster..."

# Configuration
CLUSTER_NAME="ecommerce-cluster"
NAMESPACE="ecommerce-apps"
SOURCE_DIR="SourceCode/ECommerceMS"
HELM_CHART="helm-charts/ecommerce-app"

# Check if KIND cluster exists
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "📦 Creating KIND cluster: $CLUSTER_NAME"
    kind create cluster --name "$CLUSTER_NAME"
else
    echo "✅ KIND cluster '$CLUSTER_NAME' already exists"
fi

# Set kubectl context
kubectl config use-context "kind-$CLUSTER_NAME"

echo "🔨 Building Docker images..."
cd "$SOURCE_DIR"

# Build images
docker build -t product-service:v1.0.0 -f ProductService/Dockerfile .
docker build -t order-service:v1.0.0 -f OrderService/Dockerfile .
docker build -t customer-service:v1.0.0 -f CustomerService/Dockerfile .
docker build -t api-gateway:v1.0.0 -f ApiGateway/Dockerfile .

echo "📥 Loading images into KIND cluster..."
kind load docker-image product-service:v1.0.0 --name "$CLUSTER_NAME"
kind load docker-image order-service:v1.0.0 --name "$CLUSTER_NAME"
kind load docker-image customer-service:v1.0.0 --name "$CLUSTER_NAME"
kind load docker-image api-gateway:v1.0.0 --name "$CLUSTER_NAME"

# Go back to root directory
cd ../..

echo "🎯 Creating namespace..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "⚡ Deploying with Helm..."
helm upgrade --install ecommerce-app "$HELM_CHART" \
  --namespace "$NAMESPACE" \
  --values "$HELM_CHART/values-kind.yaml" \
  --wait \
  --timeout=300s

echo "📊 Checking deployment status..."
kubectl get pods -n "$NAMESPACE"
kubectl get services -n "$NAMESPACE"

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📋 Access your services:"
echo "  API Gateway:      http://localhost:30080"
echo "  Product Service:  kubectl port-forward -n $NAMESPACE svc/product-service 5001:80"
echo "  Order Service:    kubectl port-forward -n $NAMESPACE svc/order-service 5002:80"
echo "  Customer Service: kubectl port-forward -n $NAMESPACE svc/customer-service 5003:80"
echo ""
echo "🔍 Useful commands:"
echo "  Watch pods:       kubectl get pods -n $NAMESPACE -w"
echo "  Check logs:       kubectl logs -n $NAMESPACE deployment/product-service"
echo "  Delete app:       helm uninstall ecommerce-app -n $NAMESPACE"
echo "  Delete cluster:   kind delete cluster --name $CLUSTER_NAME"

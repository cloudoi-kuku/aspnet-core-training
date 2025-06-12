#!/bin/bash
# Build and deploy script for Azure Container Apps
# This script builds the Docker images with the correct environment variables after infrastructure is created

set -e

echo "=== Building and Deploying Microservices ==="

# Get Terraform outputs
echo "Getting deployment information from Terraform..."
BACKEND_URL=$(terraform output -raw backend_url)
ACR_NAME=$(terraform output -raw acr_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

if [ -z "$BACKEND_URL" ] || [ -z "$ACR_NAME" ]; then
    echo "Error: Could not get Terraform outputs. Make sure 'terraform apply' has been run first."
    exit 1
fi

echo "Backend URL: $BACKEND_URL"
echo "ACR Name: $ACR_NAME"
echo "Resource Group: $RESOURCE_GROUP"

# Login to ACR
echo "Logging in to Azure Container Registry..."
az acr login --name $ACR_NAME

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

# Build and push Backend
echo "Building Backend API..."
cd ../src/backend/ECommerce.API
az acr build --registry $ACR_NAME --image ecommerce-backend:latest . --platform linux/amd64

# Build and push Frontend with the backend URL
echo "Building Frontend with API URL: $BACKEND_URL"
cd ../../frontend
az acr build --registry $ACR_NAME --image ecommerce-frontend:latest . --platform linux/amd64 --build-arg NEXT_PUBLIC_API_URL=$BACKEND_URL

# Update the container apps to use the new images
echo "Updating Backend Container App..."
az containerapp update \
    --name ecommerce-backend \
    --resource-group $RESOURCE_GROUP \
    --image $ACR_NAME.azurecr.io/ecommerce-backend:latest

echo "Updating Frontend Container App..."
az containerapp update \
    --name ecommerce-frontend \
    --resource-group $RESOURCE_GROUP \
    --image $ACR_NAME.azurecr.io/ecommerce-frontend:latest

echo "=== Deployment Complete ==="
echo "Frontend URL: $(terraform output -raw frontend_url)"
echo "Backend URL: $BACKEND_URL"
echo "Swagger UI: $BACKEND_URL/swagger/index.html"
# Build and deploy script for Azure Container Apps
# This script builds the Docker images with the correct environment variables after infrastructure is created

Write-Host "=== Building and Deploying Microservices ===" -ForegroundColor Green

# Get Terraform outputs
Write-Host "Getting deployment information from Terraform..." -ForegroundColor Yellow

# Function to get clean terraform output
function Get-TerraformOutput {
    param($OutputName)
    $output = & terraform output -raw $OutputName 2>&1
    if ($output -is [array]) {
        $output = $output | Where-Object { $_ -and $_ -notmatch "Warning:|│|╵|╷" -and $_.Trim() -ne "" } | Select-Object -First 1
    }
    return $output
}

$BACKEND_URL = Get-TerraformOutput "backend_url"
$ACR_NAME = Get-TerraformOutput "acr_name"
$RESOURCE_GROUP = Get-TerraformOutput "resource_group_name"

if ([string]::IsNullOrEmpty($BACKEND_URL) -or [string]::IsNullOrEmpty($ACR_NAME)) {
    Write-Host "Error: Could not get Terraform outputs. Make sure 'terraform apply' has been run first." -ForegroundColor Red
    exit 1
}

Write-Host "Backend URL: $BACKEND_URL" -ForegroundColor Cyan
Write-Host "ACR Name: $ACR_NAME" -ForegroundColor Cyan
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan

# Login to ACR
Write-Host "Logging in to Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME

# Get the script directory and move to terraform root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path "$ScriptDir/.."

# Build and push Backend
Write-Host "Building Backend API..." -ForegroundColor Yellow
Set-Location -Path "src/backend/ECommerce.API"
az acr build --registry $ACR_NAME --image ecommerce-backend:latest . --platform linux/amd64

# Build and push Frontend with the backend URL
Write-Host "Building Frontend with API URL: $BACKEND_URL" -ForegroundColor Yellow
Set-Location -Path "$ScriptDir/../src/frontend"
az acr build --registry $ACR_NAME --image ecommerce-frontend:latest . --platform linux/amd64 --build-arg NEXT_PUBLIC_API_URL=$BACKEND_URL

# Update the container apps to use the new images
Write-Host "Updating Backend Container App..." -ForegroundColor Yellow
az containerapp update `
    --name ecommerce-backend `
    --resource-group $RESOURCE_GROUP `
    --image "$ACR_NAME.azurecr.io/ecommerce-backend:latest"

Write-Host "Updating Frontend Container App..." -ForegroundColor Yellow
az containerapp update `
    --name ecommerce-frontend `
    --resource-group $RESOURCE_GROUP `
    --image "$ACR_NAME.azurecr.io/ecommerce-frontend:latest"

Write-Host "=== Deployment Complete ===" -ForegroundColor Green
$FRONTEND_URL = Get-TerraformOutput "frontend_url"
Write-Host "Frontend URL: $FRONTEND_URL" -ForegroundColor Cyan
Write-Host "Backend URL: $BACKEND_URL" -ForegroundColor Cyan
Write-Host "Swagger UI: $BACKEND_URL/swagger/index.html" -ForegroundColor Cyan
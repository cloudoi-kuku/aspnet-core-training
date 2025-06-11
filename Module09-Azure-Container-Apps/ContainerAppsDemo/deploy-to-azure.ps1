#!/usr/bin/env pwsh

# Azure Container Apps Deployment Script
param(
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus"
)

# Prompt for Student ID
Write-Host "Please enter your Student ID (this will be used to create unique Azure resources):" -ForegroundColor Cyan
$STUDENT_ID = Read-Host "Student ID"
if ([string]::IsNullOrWhiteSpace($STUDENT_ID)) {
    Write-Error "Student ID cannot be empty!"
    exit 1
}

# Sanitize student ID for Azure naming (lowercase, alphanumeric only)
$STUDENT_ID_CLEAN = ($STUDENT_ID -replace '[^a-zA-Z0-9]', '').ToLower()
if ($STUDENT_ID_CLEAN.Length -gt 20) {
    $STUDENT_ID_CLEAN = $STUDENT_ID_CLEAN.Substring(0, 20)
}

# Generate unique resource names with student ID
$ResourceGroupName = "rg-containerappsdemo-$STUDENT_ID_CLEAN"
$ContainerAppName = "containerapp-$STUDENT_ID_CLEAN"
$RANDOM_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$RegistryName = "acrcad$STUDENT_ID_CLEAN$RANDOM_SUFFIX"

Write-Host "🚀 Starting Azure Container Apps deployment..." -ForegroundColor Cyan
Write-Host "Student: $STUDENT_ID" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host "Location: $Location" -ForegroundColor Yellow
Write-Host "Container App: $ContainerAppName" -ForegroundColor Yellow
Write-Host "Registry: $RegistryName" -ForegroundColor Yellow
Write-Host ""

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI not found. Please install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Login check
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$loginStatus = az account show --query "user.name" -o tsv 2>$null
if (-not $loginStatus) {
    Write-Host "Please login to Azure..." -ForegroundColor Red
    az login
}

Write-Host "Logged in as: $loginStatus" -ForegroundColor Green

# Install Container Apps extension
Write-Host "Installing Azure Container Apps extension..." -ForegroundColor Yellow
az extension add --name containerapp --upgrade

# Register required resource providers
Write-Host "Registering required resource providers..." -ForegroundColor Yellow
az provider register -n Microsoft.App --wait
az provider register -n Microsoft.OperationalInsights --wait
Write-Host "Resource providers registered successfully!" -ForegroundColor Green

# Create resource group
Write-Host "Creating resource group for Student: $STUDENT_ID..." -ForegroundColor Yellow
Write-Host "Resource Group Name: $ResourceGroupName" -ForegroundColor Cyan
az group create --name $ResourceGroupName --location $Location --tags "enablon:contact=$STUDENT_ID@example.com" "enablon:owner=Environmental" "enablon:client=Enablon Internal" "enablon:cost_center=Environmental"

# Create Azure Container Registry
Write-Host "Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create --resource-group $ResourceGroupName --name $RegistryName --sku Basic --admin-enabled true

# Get ACR login server
$acrLoginServer = az acr show --name $RegistryName --query loginServer --output tsv
Write-Host "ACR Login Server: $acrLoginServer" -ForegroundColor Green

# Build and push image to ACR
Write-Host "Building and pushing container image..." -ForegroundColor Yellow
az acr build --registry $RegistryName --image containerappsdemo:latest .

# Create Log Analytics workspace for Container Apps
Write-Host "Creating Log Analytics workspace..." -ForegroundColor Yellow
$workspaceName = "law-$STUDENT_ID_CLEAN-$(Get-Random -Minimum 100 -Maximum 999)"
$workspaceId = az monitor log-analytics workspace create `
    --resource-group $ResourceGroupName `
    --workspace-name $workspaceName `
    --location $Location `
    --query customerId `
    --output tsv

$workspaceKey = az monitor log-analytics workspace get-shared-keys `
    --resource-group $ResourceGroupName `
    --workspace-name $workspaceName `
    --query primarySharedKey `
    --output tsv

# Create Container Apps environment
Write-Host "Creating Container Apps environment..." -ForegroundColor Yellow
$environmentName = "cae-$STUDENT_ID_CLEAN-env"
az containerapp env create `
    --name $environmentName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --logs-workspace-id $workspaceId `
    --logs-workspace-key $workspaceKey

# Get ACR credentials
$acrUsername = az acr credential show --name $RegistryName --query username --output tsv
$acrPassword = az acr credential show --name $RegistryName --query passwords[0].value --output tsv

# Create Container App
Write-Host "Creating Container App..." -ForegroundColor Yellow
az containerapp create `
    --name $ContainerAppName `
    --resource-group $ResourceGroupName `
    --environment $environmentName `
    --image "$acrLoginServer/containerappsdemo:latest" `
    --target-port 8080 `
    --ingress external `
    --registry-server $acrLoginServer `
    --registry-username $acrUsername `
    --registry-password $acrPassword `
    --cpu 0.25 `
    --memory 0.5Gi `
    --min-replicas 0 `
    --max-replicas 10

# Get Container App URL
$appUrl = az containerapp show --name $ContainerAppName --resource-group $ResourceGroupName --query properties.configuration.ingress.fqdn --output tsv

Write-Host ""
Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Information:" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "Container Registry: $acrLoginServer" -ForegroundColor White
Write-Host "Container App URL: https://$appUrl" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Useful commands:" -ForegroundColor Yellow
Write-Host "View logs: az containerapp logs show --name $ContainerAppName --resource-group $ResourceGroupName --follow" -ForegroundColor White
Write-Host "Scale app: az containerapp update --name $ContainerAppName --resource-group $ResourceGroupName --min-replicas 1 --max-replicas 5" -ForegroundColor White
Write-Host "Delete resources: az group delete --name $ResourceGroupName --yes --no-wait" -ForegroundColor White

# Save deployment info
$deploymentInfo = @"
# Azure Container Apps Deployment Information
Generated: $(Get-Date)
Student ID: $STUDENT_ID

## Resources Created
- Resource Group: $ResourceGroupName
- Container Registry: $acrLoginServer
- Container App: $ContainerAppName
- Environment: $environmentName

## URLs
- Application: https://$appUrl
- Health Check: https://$appUrl/health
- API Docs: https://$appUrl/swagger

## Management Commands
# View application logs
az containerapp logs show --name $ContainerAppName --resource-group $ResourceGroupName --follow

# Scale the application
az containerapp update --name $ContainerAppName --resource-group $ResourceGroupName --min-replicas 1 --max-replicas 5

# Update the application
az containerapp update --name $ContainerAppName --resource-group $ResourceGroupName --image $acrLoginServer/containerappsdemo:v2

# Clean up resources
az group delete --name $ResourceGroupName --yes --no-wait
"@

$deploymentInfo | Out-File -FilePath "deployment-info.txt" -Encoding UTF8
Write-Host "📄 Deployment information saved to deployment-info.txt" -ForegroundColor Green

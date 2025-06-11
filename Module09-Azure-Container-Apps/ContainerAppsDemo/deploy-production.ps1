#!/usr/bin/env pwsh

# Production deployment with monitoring and custom domain
param(
    [Parameter(Mandatory=$true)]
    [string]$CustomDomain,

    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-containerappsdemo-prod"
)

Write-Host "🚀 Deploying production environment with advanced configuration..." -ForegroundColor Cyan

# Create Application Insights
Write-Host "Creating Application Insights..." -ForegroundColor Yellow
$appInsightsName = "ai-containerappsdemo-prod"
az monitor app-insights component create --app $appInsightsName --location eastus --resource-group $ResourceGroupName

# Get Application Insights connection string
$connectionString = az monitor app-insights component show --app $appInsightsName --resource-group $ResourceGroupName --query connectionString --output tsv

# Update Container App with Application Insights
Write-Host "Configuring Application Insights..." -ForegroundColor Yellow
az containerapp update --name containerappsdemo --resource-group $ResourceGroupName --set-env-vars APPLICATIONINSIGHTS_CONNECTION_STRING="$connectionString"

# Configure custom domain (requires certificate)
Write-Host "Setting up custom domain: $CustomDomain" -ForegroundColor Yellow
az containerapp hostname add --hostname $CustomDomain --name containerappsdemo --resource-group $ResourceGroupName

Write-Host "✅ Production deployment completed!" -ForegroundColor Green

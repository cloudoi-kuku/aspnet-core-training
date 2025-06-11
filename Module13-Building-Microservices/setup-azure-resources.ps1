# Azure Microservices Setup Script (PowerShell)
# This script sets up all required Azure resources for the microservices module

Write-Host "🚀 Azure Microservices Setup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Check if Azure CLI is installed
try {
    $azVersion = az --version
    Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
$account = az account show 2>$null
if (!$account) {
    Write-Host "📝 Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Get current subscription
$subscription = az account show | ConvertFrom-Json
Write-Host ""
Write-Host "📋 Current subscription: $($subscription.name) ($($subscription.id))" -ForegroundColor Cyan
$confirm = Read-Host "Is this correct? (y/n)"

if ($confirm -ne 'y') {
    Write-Host "Please run 'az account set --subscription YOUR_SUBSCRIPTION_ID' first" -ForegroundColor Yellow
    exit 1
}

# Set variables
$RESOURCE_GROUP = "rg-microservices-demo"
$LOCATION = "eastus"
$RANDOM_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$ACR_NAME = "acrmicroservices$RANDOM_SUFFIX"
$ENVIRONMENT = "microservices-env"
$SQL_SERVER = "sql-microservices-$RANDOM_SUFFIX"
$SQL_ADMIN = "sqladmin"
$SQL_PASSWORD = "P@ssw0rd$RANDOM_SUFFIX!"
$APP_INSIGHTS = "appi-microservices"

Write-Host ""
Write-Host "📦 Creating resources with:" -ForegroundColor Cyan
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  Location: $LOCATION"
Write-Host "  ACR Name: $ACR_NAME"
Write-Host ""

# Create Resource Group
Write-Host "1️⃣ Creating Resource Group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION --tags Environment=Training Project=Microservices Module=Module13 CreatedBy=TrainingScript --output table

# Create Container Registry
Write-Host "2️⃣ Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true `
  --output table

# Create Container Apps Environment
Write-Host "3️⃣ Creating Container Apps Environment..." -ForegroundColor Yellow
az containerapp env create `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --output table

# Create SQL Server
Write-Host "4️⃣ Creating Azure SQL Server..." -ForegroundColor Yellow
az sql server create `
  --name $SQL_SERVER `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD `
  --output table

# Configure SQL Firewall
Write-Host "5️⃣ Configuring SQL Firewall..." -ForegroundColor Yellow
az sql server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0 `
  --output table

# Create Databases
Write-Host "6️⃣ Creating Databases..." -ForegroundColor Yellow
az sql db create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name ProductDb `
  --edition Basic `
  --output table

az sql db create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name OrderDb `
  --edition Basic `
  --output table

# Create Application Insights
Write-Host "7️⃣ Creating Application Insights..." -ForegroundColor Yellow
az monitor app-insights component create `
  --app $APP_INSIGHTS `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web `
  --output table

# Get connection information
Write-Host ""
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green

$ACR_LOGIN_SERVER = az acr show --name $ACR_NAME --query loginServer -o tsv
$INSTRUMENTATION_KEY = az monitor app-insights component show --app $APP_INSIGHTS --resource-group $RESOURCE_GROUP --query instrumentationKey -o tsv

# Save configuration
$configContent = @"
# Azure Configuration for Microservices Module
`$RESOURCE_GROUP="$RESOURCE_GROUP"
`$LOCATION="$LOCATION"
`$ACR_NAME="$ACR_NAME"
`$ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER"
`$ENVIRONMENT="$ENVIRONMENT"
`$SQL_SERVER="$SQL_SERVER"
`$SQL_ADMIN="$SQL_ADMIN"
`$SQL_PASSWORD="$SQL_PASSWORD"
`$APP_INSIGHTS="$APP_INSIGHTS"
`$INSTRUMENTATION_KEY="$INSTRUMENTATION_KEY"

# Connection Strings
`$PRODUCT_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=ProductDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
`$ORDER_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=OrderDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
`$APP_INSIGHTS_CONNECTION="InstrumentationKey=`$INSTRUMENTATION_KEY"

Write-Host "Azure configuration loaded!" -ForegroundColor Green
"@

Set-Content -Path "azure-config.ps1" -Value $configContent

Write-Host ""
Write-Host "📝 Configuration saved to: azure-config.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔐 Important credentials:" -ForegroundColor Yellow
Write-Host "  SQL Admin: $SQL_ADMIN"
Write-Host "  SQL Password: $SQL_PASSWORD"
Write-Host ""
Write-Host "💰 Estimated monthly cost: `$15-20 (with minimal usage)" -ForegroundColor Yellow
Write-Host ""
Write-Host "🧹 To clean up resources later, run:" -ForegroundColor Yellow
Write-Host "  az group delete --name $RESOURCE_GROUP --yes --no-wait" -ForegroundColor White
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Load the configuration: . .\azure-config.ps1" -ForegroundColor White
Write-Host "  2. Continue with Exercise 2 to build your services" -ForegroundColor White
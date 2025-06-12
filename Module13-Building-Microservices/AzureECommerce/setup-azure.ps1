# Azure Microservices Setup Script
# This script sets up all required Azure resources

Write-Host "🚀 Setting up Azure resources for microservices..." -ForegroundColor Cyan

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

# Variables
$RESOURCE_GROUP = "rg-microservices-$STUDENT_ID_CLEAN"
$LOCATION = "westus"
$RANDOM_SUFFIX = Get-Random -Minimum 1000 -Maximum 9999
$ACR_NAME = "acrms$STUDENT_ID_CLEAN$RANDOM_SUFFIX"
$ENVIRONMENT = "ms-env-$STUDENT_ID_CLEAN"
$SQL_SERVER = "sql-ms-$STUDENT_ID_CLEAN-$RANDOM_SUFFIX"
$SQL_ADMIN = "sqladmin"
$SQL_PASSWORD = "P@ssw0rd$RANDOM_SUFFIX!"
$APP_INSIGHTS = "appi-ms-$STUDENT_ID_CLEAN"

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it first."
    exit 1
}

# Login check
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

Write-Host "Creating resource group for Student: $STUDENT_ID..." -ForegroundColor Yellow
Write-Host "Resource Group Name: $RESOURCE_GROUP" -ForegroundColor Cyan

# Prompt for required tags
Write-Host ""
Write-Host "Your organization requires specific tags for Azure resources." -ForegroundColor Yellow
Write-Host "Please provide the following information:" -ForegroundColor Cyan

$COST_CENTER = Read-Host "Cost Center (e.g., IT-Training)"
$OWNER = Read-Host "Owner Name (e.g., John Doe)"
$CONTACT = Read-Host "Contact Email (e.g., john.doe@company.com)"

az group create --name $RESOURCE_GROUP --location $LOCATION --tags `
    "enablon:client=Enablon Internal" `
    "enablon:cost_center=$COST_CENTER" `
    "enablon:owner=$OWNER" `
    "enablon:contact=$CONTACT" `
    Environment=Training `
    Project=Microservices `
    Module=Module13 `
    StudentID=$STUDENT_ID `
    CreatedBy=TrainingScript

Write-Host "Creating Container Registry..." -ForegroundColor Yellow
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true

Write-Host "Creating Container Apps Environment..." -ForegroundColor Yellow
az containerapp env create `
  --name $ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

Write-Host "Creating SQL Server..." -ForegroundColor Yellow
az sql server create `
  --name $SQL_SERVER `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD

az sql server firewall-rule create `
  --resource-group $RESOURCE_GROUP `
  --server $SQL_SERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0

Write-Host "Creating databases..." -ForegroundColor Yellow
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name ProductDb --edition Basic
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name OrderDb --edition Basic

Write-Host "Creating Application Insights..." -ForegroundColor Yellow
az monitor app-insights component create `
  --app $APP_INSIGHTS `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web `
  --tags `
    "enablon:client=Enablon Internal" `
    "enablon:cost_center=$COST_CENTER" `
    "enablon:owner=$OWNER" `
    "enablon:contact=$CONTACT"

# Get connection information
$ACR_LOGIN_SERVER = az acr show --name $ACR_NAME --query loginServer -o tsv
$INSTRUMENTATION_KEY = az monitor app-insights component show --app $APP_INSIGHTS --resource-group $RESOURCE_GROUP --query instrumentationKey -o tsv

# Save configuration
$config = @"
# Azure Configuration
`$STUDENT_ID="$STUDENT_ID"
`$STUDENT_ID_CLEAN="$STUDENT_ID_CLEAN"
`$RESOURCE_GROUP="$RESOURCE_GROUP"
`$ACR_NAME="$ACR_NAME"
`$ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER"
`$ENVIRONMENT="$ENVIRONMENT"
`$SQL_SERVER="$SQL_SERVER"
`$SQL_ADMIN="$SQL_ADMIN"
`$SQL_PASSWORD="$SQL_PASSWORD"
`$APP_INSIGHTS="$APP_INSIGHTS"
`$INSTRUMENTATION_KEY="$INSTRUMENTATION_KEY"
`$PRODUCT_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=ProductDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
`$ORDER_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=OrderDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
`$APP_INSIGHTS_CONNECTION="InstrumentationKey=${INSTRUMENTATION_KEY}"

# Required Tags
`$COST_CENTER="$COST_CENTER"
`$OWNER="$OWNER"
`$CONTACT="$CONTACT"
"@

$config | Out-File -FilePath "azure-config.ps1"

Write-Host "\n✅ Setup complete!" -ForegroundColor Green
Write-Host "Configuration saved to azure-config.ps1" -ForegroundColor Cyan
Write-Host "\nEstimated monthly cost: ~`$30 (minimal usage)" -ForegroundColor Yellow

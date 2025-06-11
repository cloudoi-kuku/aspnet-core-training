#!/bin/bash

# Azure Microservices Setup Script
# This script sets up all required Azure resources for the microservices module

set -e

echo "🚀 Azure Microservices Setup Script"
echo "=================================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "📝 Please login to Azure..."
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "📋 Current subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
read -p "Is this correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please run 'az account set --subscription YOUR_SUBSCRIPTION_ID' first"
    exit 1
fi

# Set variables
RESOURCE_GROUP="rg-microservices-demo"
LOCATION="eastus"
RANDOM_SUFFIX=$(openssl rand -hex 2)
ACR_NAME="acrmicroservices${RANDOM_SUFFIX}"
ENVIRONMENT="microservices-env"
SQL_SERVER="sql-microservices-${RANDOM_SUFFIX}"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd${RANDOM_SUFFIX}!"
APP_INSIGHTS="appi-microservices"

echo ""
echo "📦 Creating resources with:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  ACR Name: $ACR_NAME"
echo ""

# Create Resource Group
echo "1️⃣ Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION --tags Environment=Training Project=Microservices Module=Module13 CreatedBy=TrainingScript --output table

# Create Container Registry
echo "2️⃣ Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true \
  --output table

# Create Container Apps Environment
echo "3️⃣ Creating Container Apps Environment..."
az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --output table

# Create SQL Server
echo "4️⃣ Creating Azure SQL Server..."
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD \
  --output table

# Configure SQL Firewall
echo "5️⃣ Configuring SQL Firewall..."
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

# Create Databases
echo "6️⃣ Creating Databases..."
az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name ProductDb \
  --edition Basic \
  --output table

az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name OrderDb \
  --edition Basic \
  --output table

# Create Application Insights
echo "7️⃣ Creating Application Insights..."
az monitor app-insights component create \
  --app $APP_INSIGHTS \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web \
  --output table

# Get connection information
echo ""
echo "✅ Setup Complete!"
echo "================="

ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
INSTRUMENTATION_KEY=$(az monitor app-insights component show --app $APP_INSIGHTS --resource-group $RESOURCE_GROUP --query instrumentationKey -o tsv)

# Save configuration
cat > azure-config.sh << EOF
#!/bin/bash
# Azure Configuration for Microservices Module
export RESOURCE_GROUP="$RESOURCE_GROUP"
export LOCATION="$LOCATION"
export ACR_NAME="$ACR_NAME"
export ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER"
export ENVIRONMENT="$ENVIRONMENT"
export SQL_SERVER="$SQL_SERVER"
export SQL_ADMIN="$SQL_ADMIN"
export SQL_PASSWORD="$SQL_PASSWORD"
export APP_INSIGHTS="$APP_INSIGHTS"
export INSTRUMENTATION_KEY="$INSTRUMENTATION_KEY"

# Connection Strings
export PRODUCT_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=ProductDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
export ORDER_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=OrderDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
export APP_INSIGHTS_CONNECTION="InstrumentationKey=$INSTRUMENTATION_KEY"

echo "Azure configuration loaded!"
EOF

# Save PowerShell configuration
cat > azure-config.ps1 << EOF
# Azure Configuration for Microservices Module
\$RESOURCE_GROUP="$RESOURCE_GROUP"
\$LOCATION="$LOCATION"
\$ACR_NAME="$ACR_NAME"
\$ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER"
\$ENVIRONMENT="$ENVIRONMENT"
\$SQL_SERVER="$SQL_SERVER"
\$SQL_ADMIN="$SQL_ADMIN"
\$SQL_PASSWORD="$SQL_PASSWORD"
\$APP_INSIGHTS="$APP_INSIGHTS"
\$INSTRUMENTATION_KEY="$INSTRUMENTATION_KEY"

# Connection Strings
\$PRODUCT_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=ProductDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
\$ORDER_DB_CONNECTION="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=OrderDb;User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;"
\$APP_INSIGHTS_CONNECTION="InstrumentationKey=\$INSTRUMENTATION_KEY"

Write-Host "Azure configuration loaded!" -ForegroundColor Green
EOF

chmod +x azure-config.sh

echo ""
echo "📝 Configuration saved to:"
echo "  - azure-config.sh (for Linux/Mac)"
echo "  - azure-config.ps1 (for Windows PowerShell)"
echo ""
echo "🔐 Important credentials:"
echo "  SQL Admin: $SQL_ADMIN"
echo "  SQL Password: $SQL_PASSWORD"
echo ""
echo "💰 Estimated monthly cost: \$15-20 (with minimal usage)"
echo ""
echo "🧹 To clean up resources later, run:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
echo "📚 Next steps:"
echo "  1. Source the configuration: source ./azure-config.sh"
echo "  2. Continue with Exercise 2 to build your services"
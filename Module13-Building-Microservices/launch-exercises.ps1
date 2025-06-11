#!/usr/bin/env pwsh

# Module 13: Building Microservices - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for microservices architecture and implementation

param(
    [Parameter(Position=0)]
    [string]$ExerciseName,
    
    [switch]$List,
    [switch]$Auto,
    [switch]$Preview
)

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$ProjectName = "AzureECommerce"
$InteractiveMode = -not $Auto
$SkipProjectCreation = $false
$PreviewOnly = $Preview
$ExerciseType = "Azure" # Default to Azure-focused exercises

# Colors for output
function Write-Info { 
    Write-Host "ℹ️  $($args[0])" -ForegroundColor Blue 
}

function Write-Success { 
    Write-Host "✅ $($args[0])" -ForegroundColor Green 
}

function Write-Warning { 
    Write-Host "⚠️  $($args[0])" -ForegroundColor Yellow 
}

function Write-Error { 
    Write-Host "❌ $($args[0])" -ForegroundColor Red 
}

function Write-Concept {
    param(
        [string]$Title,
        [string]$Content
    )
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "🏗️ MICROSERVICES CONCEPT: $Title" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host $Content -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host ""
}

# Function to pause for user interaction
function Pause-ForUser {
    if ($InteractiveMode) {
        Write-Host -NoNewline "Press Enter to continue..."
        Read-Host
        Write-Host ""
    }
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)
    
    Write-Host "🎯 Microservices Learning Objectives for ${Exercise}:" -ForegroundColor Blue
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "Azure Setup and Microservices Overview:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Set up Azure Resource Group with unique Student ID"
            Write-Host "  ☁️  2. Create Azure Container Registry (ACR)"
            Write-Host "  ☁️  3. Create Container Apps Environment"
            Write-Host "  ☁️  4. Set up Azure SQL Database and Application Insights"
            Write-Host ""
            Write-Host "Azure concepts:" -ForegroundColor Yellow
            Write-Host "  • Azure Container Apps fundamentals"
            Write-Host "  • Resource naming with Student ID"
            Write-Host "  • Cost estimation (~`$30/month)"
            Write-Host "  • Cloud-native design principles"
        }
        "exercise02" {
            Write-Host "Building Azure-Ready Services:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Create ProductService microservice"
            Write-Host "  ☁️  2. Create OrderService microservice"
            Write-Host "  ☁️  3. Configure for Azure SQL Database"
            Write-Host "  ☁️  4. Add health checks and Dockerfiles"
            Write-Host ""
            Write-Host "Azure integration concepts:" -ForegroundColor Yellow
            Write-Host "  • Azure SQL Database connection strings"
            Write-Host "  • Application Insights integration"
            Write-Host "  • Docker containerization"
            Write-Host "  • Service-to-service communication"
        }
        "exercise03" {
            Write-Host "Deploy to Azure Container Apps:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Build and push images to Azure Container Registry"
            Write-Host "  ☁️  2. Deploy services to Container Apps"
            Write-Host "  ☁️  3. Configure auto-scaling rules"
            Write-Host "  ☁️  4. Test service communication"
            Write-Host ""
            Write-Host "Deployment concepts:" -ForegroundColor Yellow
            Write-Host "  • ACR authentication and image push"
            Write-Host "  • Container Apps ingress configuration"
            Write-Host "  • Auto-scaling with min/max replicas"
            Write-Host "  • Service URL discovery"
        }
        "exercise04" {
            Write-Host "Resilient Service Communication:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Add Polly for resilience patterns"
            Write-Host "  ☁️  2. Implement retry and circuit breaker"
            Write-Host "  ☁️  3. Configure health checks"
            Write-Host "  ☁️  4. Handle transient failures"
            Write-Host ""
            Write-Host "Communication concepts:" -ForegroundColor Yellow
            Write-Host "  • HTTP resilience with Polly"
            Write-Host "  • Circuit breaker implementation"
            Write-Host "  • Health check endpoints"
            Write-Host "  • Graceful degradation"
        }
        "exercise05" {
            Write-Host "Production Deployment Options:" -ForegroundColor Cyan
            Write-Host "  ☁️  1. Option A: Deploy to Azure AKS with Terraform"
            Write-Host "  ☁️  2. Option B: Deploy to Docker Swarm"
            Write-Host "  ☁️  3. Option C: Deploy to generic Kubernetes"
            Write-Host "  ☁️  4. Set up monitoring and scaling"
            Write-Host ""
            Write-Host "Production concepts:" -ForegroundColor Yellow
            Write-Host "  • Infrastructure as Code with Terraform"
            Write-Host "  • Kubernetes deployments and services"
            Write-Host "  • Production monitoring setup"
            Write-Host "  • Cost and complexity comparison"
        }
    }
    Write-Host ""
}

# Function to show what will be created
function Show-CreationOverview {
    param([string]$Exercise)
    
    Write-Host "📋 Microservices Components for ${Exercise}:" -ForegroundColor Cyan
    
    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Azure resource setup script (setup-azure.ps1)"
            Write-Host "• Unique Student ID configuration"
            Write-Host "• Resource Group, ACR, Container Apps Environment"
            Write-Host "• Azure SQL Server with ProductDb and OrderDb"
            Write-Host "• Application Insights for monitoring"
            Write-Host "• Cost estimation documentation"
        }
        "exercise02" {
            Write-Host "• ProductService with Azure SQL integration"
            Write-Host "• OrderService with service-to-service calls"
            Write-Host "• Health check endpoints"
            Write-Host "• Dockerfiles for containerization"
            Write-Host "• Azure-ready configuration"
        }
        "exercise03" {
            Write-Host "• Deploy script for Azure Container Apps"
            Write-Host "• ACR image build and push"
            Write-Host "• Container Apps deployment with auto-scaling"
            Write-Host "• Service URL configuration"
            Write-Host "• Testing scripts for deployed services"
        }
        "exercise04" {
            Write-Host "• Polly resilience library integration"
            Write-Host "• Retry policies for transient failures"
            Write-Host "• Circuit breaker implementation"
            Write-Host "• Enhanced health check endpoints"
            Write-Host "• Failure testing scenarios"
        }
        "exercise05" {
            Write-Host "• Option A: Azure AKS with Terraform IaC"
            Write-Host "• Option B: Docker Swarm (cloud-agnostic)"
            Write-Host "• Option C: Generic Kubernetes manifests"
            Write-Host "• Monitoring and observability setup"
            Write-Host "• Deployment comparison guide"
        }
    }
    Write-Host ""
}

# Function to create files interactively
function New-FileInteractive {
    param(
        [string]$FilePath,
        [string]$Content,
        [string]$Description
    )
    
    if ($PreviewOnly) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $directory = Split-Path -Parent $FilePath
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host -NoNewline "   File created. Press Enter to continue..."
        Read-Host
    }
    Write-Host ""
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 13 - Building Microservices with Azure" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Azure Setup and Microservices Overview"
    Write-Host "  - exercise02: Building Azure-Ready Services"
    Write-Host "  - exercise03: Deploy to Azure Container Apps"
    Write-Host "  - exercise04: Azure Service Communication"
    Write-Host "  - exercise05: Production Features"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List          Show all available exercises"
    Write-Host "  -Auto          Skip interactive mode"
    Write-Host "  -Preview       Show what will be created without creating"
}

# Main script starts here
if ($List) {
    Show-Exercises
    exit 0
}

if (-not $ExerciseName) {
    Write-Error "Usage: .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Validate exercise name
if ($ExerciseName -notin @("exercise01", "exercise02", "exercise03", "exercise04", "exercise05")) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "☁️ Module 13: Building Microservices with Azure" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""

# Show learning objectives
Show-LearningObjectives $ExerciseName

# Show what will be created
Show-CreationOverview $ExerciseName

if ($PreviewOnly) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking microservices prerequisites..."

# Check .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Success ".NET SDK $dotnetVersion is installed"
} catch {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

# Check Azure CLI
try {
    $azVersion = az --version | Select-String "azure-cli" | Select-Object -First 1
    Write-Success "Azure CLI is installed: $azVersion"
} catch {
    Write-Error "Azure CLI is not installed. Please install Azure CLI to continue."
    Write-Info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists in current directory
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04", "exercise05")) {
        Write-Success "Found existing $ProjectName from previous exercise"
        Write-Info "This exercise will build on your existing work"
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Warning "Project '$ProjectName' already exists!"
        $response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            exit 1
        }
        Remove-Item -Path $ProjectName -Recurse -Force
        $SkipProjectCreation = $false
    }
} else {
    $SkipProjectCreation = $false
}

# Exercise implementations
switch ($ExerciseName) {
    "exercise01" {
        # Exercise 1: Azure Setup and Microservices Overview
        
        Write-Concept -Title "Azure Container Apps for Microservices" -Content @"
Azure Container Apps - Serverless Microservices:
• No Infrastructure Management: Focus on code, not servers
• Auto-scaling: Scale to zero, scale based on demand
• Built-in Features: Load balancing, HTTPS, service discovery
• Cost-Effective: Pay only for what you use
• Integrated Services: Azure SQL, Service Bus, Key Vault
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Info "Setting up Azure resources..."
            New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
            Set-Location $ProjectName
        }
        
        # Create Azure setup script
        New-FileInteractive -FilePath "setup-azure.ps1" -Content @'
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
$LOCATION = "eastus"
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
  --application-type web

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
'@ -Description "Azure resource setup script for microservices"
        
        # Create cost estimation
        New-FileInteractive -FilePath "docs\azure-cost-estimation.md" -Content @'
# Azure Cost Estimation

## Monthly Cost Breakdown (Minimal Usage)

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| Container Apps | 2 apps, 0.5 vCPU, 1GB RAM each | ~$10 |
| Azure SQL | Basic tier, 2 databases | ~$10 |
| Container Registry | Basic tier | ~$5 |
| Application Insights | Basic ingestion | ~$5 |
| **Total** | | **~`$30/month** |

## Free Tier Benefits
- First 180,000 vCPU-seconds free
- First 360,000 GB-seconds free  
- First 2 million requests free
- 5GB Application Insights data free

## Cost Optimization Tips
1. Scale Container Apps to zero when not in use
2. Use Basic tier for SQL in development
3. Set up cost alerts in Azure Portal
4. Review and optimize regularly
'@ -Description "Azure cost estimation guide"
        
        Write-Host ""
        Write-Success "Exercise 01 setup complete!"
        Write-Host ""
        Write-Host "🚨 IMPORTANT NEXT STEP:" -ForegroundColor Yellow
        Write-Host "You MUST run the setup script to create Azure resources:" -ForegroundColor Red
        Write-Host ""
        Write-Host "  .\setup-azure.ps1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This script will:" -ForegroundColor White
        Write-Host "  • Create Azure Resource Group" -ForegroundColor Gray
        Write-Host "  • Create Container Registry" -ForegroundColor Gray
        Write-Host "  • Create Container Apps Environment" -ForegroundColor Gray
        Write-Host "  • Create SQL Server and databases" -ForegroundColor Gray
        Write-Host "  • Create Application Insights" -ForegroundColor Gray
        Write-Host "  • Generate azure-config.ps1 (required for other exercises)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "After running setup-azure.ps1, you can proceed to exercise02." -ForegroundColor Green
    }
    
    "exercise02" {
        # Exercise 2: Building Azure-Ready Services
        
        Write-Concept -Title "Cloud-Native Service Design" -Content @"
Azure-Ready Microservices:
• 12-Factor App Principles: Configuration, logging, stateless
• Azure Integration: SQL Database, Key Vault, App Insights
• Container-Ready: Dockerfile optimization for Azure
• Health Checks: Liveness and readiness probes
• Resilience: Built-in retry and circuit breaker patterns
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }
        
        Write-Info "Creating Azure-ready microservices..."
        
        # Create solution structure
        New-Item -ItemType Directory -Path "SourceCode/AzureECommerce" -Force | Out-Null
        Set-Location "SourceCode/AzureECommerce"
        dotnet new sln -n AzureECommerce
        
        # Create Product Service
        Write-Info "Creating ProductService..."
        dotnet new webapi -n ProductService --framework net8.0
        Set-Location "ProductService"
        
        # Add necessary packages
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Swashbuckle.AspNetCore
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks
        dotnet add package Microsoft.ApplicationInsights.AspNetCore
        
        Set-Location ".."
        dotnet sln add ProductService/ProductService.csproj
        
        # Create Order Service
        Write-Info "Creating OrderService..."
        dotnet new webapi -n OrderService --framework net8.0
        Set-Location "OrderService"
        
        # Add necessary packages
        dotnet add package Microsoft.EntityFrameworkCore.SqlServer
        dotnet add package Microsoft.EntityFrameworkCore.Tools
        dotnet add package Swashbuckle.AspNetCore
        dotnet add package Microsoft.AspNetCore.Diagnostics.HealthChecks
        dotnet add package Microsoft.ApplicationInsights.AspNetCore
        
        Set-Location ".."
        dotnet sln add OrderService/OrderService.csproj
        
        # Create Product model
        New-FileInteractive -FilePath "ProductService/Models/Product.cs" -Content @'
namespace ProductService.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
'@ -Description "Product model for ProductService"
        
        # Create Order model
        New-FileInteractive -FilePath "OrderService/Models/Order.cs" -Content @'
namespace OrderService.Models;

public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal TotalPrice { get; set; }
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    public string Status { get; set; } = "Pending";
}
'@ -Description "Order model for OrderService"
        
        # Create Dockerfiles
        New-FileInteractive -FilePath "ProductService/Dockerfile" -Content @'
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProductService.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProductService.dll"]
'@ -Description "Dockerfile for ProductService"
        
        New-FileInteractive -FilePath "OrderService/Dockerfile" -Content @'
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OrderService.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OrderService.dll"]
'@ -Description "Dockerfile for OrderService"
        
        Write-Success "Azure-ready microservices created successfully!"
        Set-Location "../.."
    }
    
    "exercise03" {
        # Exercise 3: Deploy to Azure Container Apps
        
        Write-Concept -Title "Azure Container Apps Deployment" -Content @"
Deploying to Azure Container Apps:
• Container Registry: Push images to Azure Container Registry
• Container Apps: Deploy without managing infrastructure
• Environment Variables: Configure services for Azure
• Service Discovery: Built-in service-to-service communication
• Monitoring: Application Insights integration
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }
        
        # Load Azure configuration
        Write-Info "Loading Azure configuration..."
        if (Test-Path "azure-config.ps1") {
            . .\azure-config.ps1
        } else {
            Write-Error "Azure configuration not found!"
            Write-Host ""
            Write-Host "Please ensure you have:" -ForegroundColor Yellow
            Write-Host "1. Run exercise01: .\launch-exercises.ps1 exercise01" -ForegroundColor White
            Write-Host "2. Run the setup script: .\setup-azure.ps1" -ForegroundColor White
            Write-Host ""
            Write-Host "The setup-azure.ps1 script creates the azure-config.ps1 file needed for this exercise." -ForegroundColor Cyan
            exit 1
        }
        
        # Create deployment script
        New-FileInteractive -FilePath "deploy-to-azure.ps1" -Content @'
# Deploy Microservices to Azure Container Apps

Write-Host "🚀 Deploying to Azure Container Apps..." -ForegroundColor Cyan

# Load configuration
if (!(Test-Path "../../azure-config.ps1")) {
    Write-Error "Please run exercise01 to create Azure resources first!"
    exit 1
}

. ../../azure-config.ps1

# Login to ACR
Write-Host "Logging into Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME

# Build and push ProductService
Write-Host "Building ProductService..." -ForegroundColor Yellow
Set-Location "ProductService"
az acr build --registry $ACR_NAME --image productservice:v1 . --platform linux/amd64
Set-Location ".."

# Build and push OrderService
Write-Host "Building OrderService..." -ForegroundColor Yellow
Set-Location "OrderService"
az acr build --registry $ACR_NAME --image orderservice:v1 . --platform linux/amd64
Set-Location ".."

# Deploy ProductService
Write-Host "Deploying ProductService to Container Apps..." -ForegroundColor Yellow
az containerapp create `
  --name product-service `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "${ACR_LOGIN_SERVER}/productservice:v1" `
  --target-port 80 `
  --ingress external `
  --min-replicas 1 `
  --max-replicas 3 `
  --env-vars `
    ConnectionStrings__DefaultConnection="$PRODUCT_DB_CONNECTION" `
    ApplicationInsights__ConnectionString="$APP_INSIGHTS_CONNECTION"

# Get Product Service URL
$PRODUCT_URL = az containerapp show --name product-service --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv

# Deploy OrderService
Write-Host "Deploying OrderService to Container Apps..." -ForegroundColor Yellow
az containerapp create `
  --name order-service `
  --resource-group $RESOURCE_GROUP `
  --environment $ENVIRONMENT `
  --image "${ACR_LOGIN_SERVER}/orderservice:v1" `
  --target-port 80 `
  --ingress external `
  --min-replicas 1 `
  --max-replicas 3 `
  --env-vars `
    ConnectionStrings__DefaultConnection="$ORDER_DB_CONNECTION" `
    ApplicationInsights__ConnectionString="$APP_INSIGHTS_CONNECTION" `
    Services__ProductService="https://$PRODUCT_URL"

# Get Order Service URL
$ORDER_URL = az containerapp show --name order-service --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "Product Service: https://$PRODUCT_URL" -ForegroundColor Cyan
Write-Host "Order Service: https://$ORDER_URL" -ForegroundColor Cyan
'@ -Description "Azure deployment script for microservices"
        
        Write-Success "Deployment scripts created! Run .\deploy-services.ps1 to deploy to Azure."
    }
    
    "exercise04" {
        # Exercise 4: Azure Service Communication
        
        Write-Concept -Title "Azure Service Bus & Resilience" -Content @"
Azure Service Communication:
• Service Bus: Reliable message delivery
• HTTP Communication: Service-to-service calls
• Polly Resilience: Retry, circuit breaker, timeout
• Health Checks: Monitor service availability
• Distributed Tracing: Application Insights correlation
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }
        
        # Create Polly resilience configuration
        New-FileInteractive -FilePath "add-resilience.ps1" -Content @'
# Add Resilience with Polly

Write-Host "Adding Polly resilience to services..." -ForegroundColor Cyan

# Add Polly to ProductService
Set-Location "ProductService"
dotnet add package Microsoft.Extensions.Http.Polly
Set-Location ".."

# Add Polly to OrderService
Set-Location "OrderService"
dotnet add package Microsoft.Extensions.Http.Polly
dotnet add package Polly
Set-Location ".."

Write-Host "✅ Polly packages added!" -ForegroundColor Green
Write-Host "\nNext steps:" -ForegroundColor Yellow
Write-Host "1. Configure retry policies in Program.cs"
Write-Host "2. Add circuit breaker for service calls"
Write-Host "3. Implement health check endpoints"
'@ -Description "Script to add Polly resilience library"
        
        # Create health check configuration
        New-FileInteractive -FilePath "configure-health-checks.ps1" -Content @'
# Configure Health Checks

Write-Host "Configuring health checks..." -ForegroundColor Cyan

$healthCheckCode = @"
// Add to Program.cs
builder.Services.AddHealthChecks()
    .AddSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        name: "database",
        tags: new[] { "db", "sql" })
    .AddCheck("self", () => HealthCheckResult.Healthy(), tags: new[] { "api" });

// Add endpoint
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("api")
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false
});
"@

Write-Host $healthCheckCode -ForegroundColor Yellow
Write-Host "\n✅ Add this code to both services!" -ForegroundColor Green
'@ -Description "Health check configuration guide"
        
        Write-Success "Azure communication configuration created!"
    }
    
    "exercise05" {
        # Exercise 5: Production Features
        
        Write-Concept -Title "Production-Ready Features" -Content @"
Production Features for Azure:
• Auto-scaling: CPU and HTTP-based scaling rules
• Azure Front Door: Global load balancing and CDN
• Health Monitoring: Comprehensive health checks
• Cost Management: Monitoring and optimization
• Security: Managed identities and Key Vault
"@
        
        Pause-ForUser
        
        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 5 requires all previous exercises to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
            exit 1
        }
        
        Write-Info "Configuring production features..."
        
        # Create deployment options guide
        New-FileInteractive -FilePath "deployment-options.md" -Content @'
# Deployment Options for Module 13

## Option A: Azure AKS with Terraform (Recommended for Azure)
- **Complexity**: High
- **Cost**: ~$100-150/month
- **Benefits**: Full Kubernetes features, auto-scaling, Azure integration
- **Use When**: Production workloads, team familiar with K8s

## Option B: Docker Swarm (Cloud-Agnostic)
- **Complexity**: Medium
- **Cost**: Varies by provider
- **Benefits**: Simpler than K8s, works anywhere
- **Use When**: Moderate scale, simpler operations

## Option C: Generic Kubernetes
- **Complexity**: High
- **Cost**: Varies by provider
- **Benefits**: Portable to any K8s cluster
- **Use When**: Multi-cloud strategy, existing K8s cluster

## Quick Start
For this training, use **Azure Container Apps** (from exercises 1-4) which provides:
- Serverless experience
- Built-in scaling
- Lower complexity
- ~`$30/month cost
'@ -Description "Deployment options comparison guide"
        
        # Create Terraform setup for Option A
        New-FileInteractive -FilePath "terraform-setup.ps1" -Content @'
# Setup Terraform for Azure AKS

Write-Host "Setting up Terraform for AKS deployment..." -ForegroundColor Cyan

# Check Terraform
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "Terraform is not installed. Please install it first."
    Write-Host "Visit: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Yellow
Set-Location "../../terraform"
terraform init

Write-Host "✅ Terraform initialized!" -ForegroundColor Green
Write-Host "\nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review terraform.tfvars"
Write-Host "2. Run: terraform plan"
Write-Host "3. Run: terraform apply"
'@ -Description "Terraform setup script for AKS"
        
        Write-Success "Production features configured!"
    }
}

# Final completion message
Write-Host ""
Write-Success "🎉 $ExerciseName template created successfully!"
Write-Host ""
Write-Info "📋 Next steps:"

switch ($ExerciseName) {
    "exercise01" {
        Write-Host "1. Run the Azure setup script: " -NoNewline
        Write-Host ".\setup-azure.ps1" -ForegroundColor Cyan
        Write-Host "2. Enter your Student ID when prompted"
        Write-Host "3. Wait for all Azure resources to be created"
        Write-Host "4. Verify azure-config.ps1 was created"
        Write-Host "5. Review the cost estimation in docs\azure-cost-estimation.md"
    }
    "exercise02" {
        Write-Host "1. Navigate to: " -NoNewline
        Write-Host "SourceCode\AzureECommerce" -ForegroundColor Cyan
        Write-Host "2. Build the solution: " -NoNewline
        Write-Host "dotnet build" -ForegroundColor Cyan
        Write-Host "3. Update Program.cs in each service for Azure SQL"
        Write-Host "4. Add health check endpoints"
        Write-Host "5. Test locally with Docker SQL Server"
    }
    "exercise03" {
        Write-Host "1. Run deployment script: " -NoNewline
        Write-Host ".\deploy-to-azure.ps1" -ForegroundColor Cyan
        Write-Host "2. Wait for ACR builds to complete"
        Write-Host "3. Verify Container Apps are created"
        Write-Host "4. Test service URLs in browser"
        Write-Host "5. Check Application Insights for telemetry"
    }
    "exercise04" {
        Write-Host "1. Add Polly packages: " -NoNewline
        Write-Host ".\add-resilience.ps1" -ForegroundColor Cyan
        Write-Host "2. Configure retry and circuit breaker policies"
        Write-Host "3. Add health checks: " -NoNewline
        Write-Host ".\configure-health-checks.ps1" -ForegroundColor Cyan
        Write-Host "4. Test failure scenarios"
        Write-Host "5. Redeploy to Azure with resilience features"
    }
    "exercise05" {
        Write-Host "1. Review deployment options in: " -NoNewline
        Write-Host "deployment-options.md" -ForegroundColor Cyan
        Write-Host "2. For Option A (AKS): " -NoNewline
        Write-Host ".\terraform-setup.ps1" -ForegroundColor Cyan
        Write-Host "3. For Option B: Use Docker Swarm deployment"
        Write-Host "4. For Option C: Use generic K8s manifests"
        Write-Host "5. Configure monitoring for chosen platform"
    }
}

Write-Host ""
Write-Info "📚 For detailed instructions, refer to the exercise files in the Exercises\ directory."
Write-Info "🔗 Additional microservices resources available in the Resources\ directory."
Write-Info "💡 Consider using the complete SourceCode implementation as a reference."
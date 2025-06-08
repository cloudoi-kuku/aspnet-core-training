#!/usr/bin/env pwsh

# Module 9: Azure Container Apps - Interactive Exercise Launcher (PowerShell)
# This script provides guided, hands-on exercises for containerization and Azure deployment

param(
    [Parameter(Mandatory=$false)]
    [string]$ExerciseName,
    
    [Parameter(Mandatory=$false)]
    [switch]$List,
    
    [Parameter(Mandatory=$false)]
    [switch]$Auto,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview
)

# Configuration
$ProjectName = "ContainerAppsDemo"
$InteractiveMode = -not $Auto

# Function to display colored output
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function to explain concepts interactively
function Explain-Concept {
    param($Concept, $Explanation)
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📚 CONCEPT: $Concept" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host $Explanation -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    if ($InteractiveMode) {
        Write-Host "Press Enter to continue..." -NoNewline
        Read-Host
        Write-Host ""
    }
}

# Function to show learning objectives
function Show-LearningObjectives {
    param([string]$Exercise)

    Write-Host "🎯 Learning Objectives for $Exercise:" -ForegroundColor Blue

    switch ($Exercise) {
        "exercise01" {
            Write-Host "• Understand Docker containerization for ASP.NET Core"
            Write-Host "• Create optimized Dockerfile with multi-stage builds"
            Write-Host "• Implement health checks and graceful shutdown"
            Write-Host "• Run and test containers locally"
        }
        "exercise02" {
            Write-Host "• Deploy applications to Azure Container Apps"
            Write-Host "• Configure Azure Container Registry"
            Write-Host "• Set up environment variables and secrets"
            Write-Host "• Configure scaling and ingress"
        }
        "exercise03" {
            Write-Host "• Implement CI/CD with GitHub Actions"
            Write-Host "• Automate container building and deployment"
            Write-Host "• Configure environment-specific deployments"
            Write-Host "• Set up deployment approvals"
        }
        "exercise04" {
            Write-Host "• Configure Application Insights monitoring"
            Write-Host "• Set up custom domains and SSL"
            Write-Host "• Implement service-to-service communication"
            Write-Host "• Configure network security"
        }
    }
    Write-Host ""
}

# Function to create files interactively
function Create-FileInteractive {
    param($FilePath, $Content, $Description)
    
    if ($Preview) {
        Write-Host "📄 Would create: $FilePath" -ForegroundColor Cyan
        Write-Host "   Description: $Description" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📄 Creating: $FilePath" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Yellow
    
    # Create directory if it doesn't exist
    $Directory = Split-Path $FilePath -Parent
    if ($Directory -and -not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    # Write content to file
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    
    if ($InteractiveMode) {
        Write-Host "   File created. Press Enter to continue..." -NoNewline
        Read-Host
    }
    Write-Host ""
}

# Function to show available exercises
function Show-Exercises {
    Write-Host "Module 9 - Azure Container Apps" -ForegroundColor Cyan
    Write-Host "Available Exercises:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  - exercise01: Basic Containerization"
    Write-Host "  - exercise02: Azure Deployment"
    Write-Host "  - exercise03: CI/CD Pipeline"
    Write-Host "  - exercise04: Advanced Configuration"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\launch-exercises.ps1 <exercise-name> [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -List           Show all available exercises"
    Write-Host "  -Auto           Skip interactive mode"
    Write-Host "  -Preview        Show what will be created without creating"
}

# Main script logic
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
$ValidExercises = @("exercise01", "exercise02", "exercise03", "exercise04")
if ($ExerciseName -notin $ValidExercises) {
    Write-Error "Unknown exercise: $ExerciseName"
    Write-Host ""
    Show-Exercises
    exit 1
}

# Welcome message
Write-Host "🚀 Module 9: Azure Container Apps" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Show learning objectives
Show-LearningObjectives -Exercise $ExerciseName

if ($Preview) {
    Write-Info "Preview mode - no files will be created"
    Write-Host ""
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed. Please install Docker Desktop."
    exit 1
}

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Warning "Azure CLI is not installed. Some exercises may require it."
}

# Check .NET SDK
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
}

Write-Success "Prerequisites check completed"
Write-Host ""

# Check if project exists
$SkipProjectCreation = $false
if (Test-Path $ProjectName) {
    if ($ExerciseName -in @("exercise02", "exercise03", "exercise04")) {
        Write-Success "Found existing $ProjectName from previous exercise"
        Write-Info "This exercise will build on your existing work"
        Set-Location $ProjectName
        $SkipProjectCreation = $true
    } else {
        Write-Warning "Project '$ProjectName' already exists!"
        $Response = Read-Host "Do you want to overwrite it? (y/N)"
        if ($Response -notmatch "^[Yy]$") {
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
        # Exercise 1: Basic Containerization

        Explain-Concept "Docker Containerization for ASP.NET Core" @"
Containerization packages your application with all its dependencies into a portable, lightweight container:
• Consistent runtime environment across development, testing, and production
• Isolation from host system and other applications
• Efficient resource utilization and fast startup times
• Easy scaling and deployment across different environments
• Version control for your entire application stack
"@

        if (-not $SkipProjectCreation) {
            Write-Info "🏗️ Creating ASP.NET Core Web API project for containerization..."

            # Create project directory
            New-Item -ItemType Directory -Name $ProjectName -Force
            Set-Location $ProjectName

            # Create ASP.NET Core Web API project
            dotnet new webapi -n "ContainerAppsDemo.API" --framework net8.0
            Set-Location "ContainerAppsDemo.API"

            # Remove default files
            Remove-Item -Path "WeatherForecast.cs" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "Controllers/WeatherForecastController.cs" -Force -ErrorAction SilentlyContinue

            Set-Location ".."
        } else {
            # We're already in the project directory from the check above
        }

        Explain-Concept "Multi-Stage Docker Builds" @"
Multi-stage builds optimize container images by separating build and runtime environments:
• Build stage: Contains SDK and build tools (larger image)
• Runtime stage: Contains only runtime and application (smaller image)
• Reduces final image size by 70-80%
• Improves security by excluding build tools from production
• Faster deployment and reduced attack surface
"@

        # Create optimized Dockerfile
        Create-FileInteractive "Dockerfile" @'
# Multi-stage Dockerfile for ASP.NET Core
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["ContainerAppsDemo.API/ContainerAppsDemo.API.csproj", "ContainerAppsDemo.API/"]
RUN dotnet restore "ContainerAppsDemo.API/ContainerAppsDemo.API.csproj"

# Copy source code and build
COPY . .
WORKDIR "/src/ContainerAppsDemo.API"
RUN dotnet build "ContainerAppsDemo.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ContainerAppsDemo.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user for security
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

# Copy published application
COPY --from=publish /app/publish .

# Configure health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Start application
ENTRYPOINT ["dotnet", "ContainerAppsDemo.API.dll"]
'@ "Optimized multi-stage Dockerfile with security best practices"

        # Create health check controller
        Create-FileInteractive "ContainerAppsDemo.API/Controllers/HealthController.cs" @'
using Microsoft.AspNetCore.Mvc;

namespace ContainerAppsDemo.API.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;

    public HealthController(ILogger<HealthController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        _logger.LogInformation("Health check requested");

        var healthStatus = new
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0",
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            MachineName = Environment.MachineName
        };

        return Ok(healthStatus);
    }

    [HttpGet("ready")]
    public IActionResult Ready()
    {
        // Add readiness checks here (database connectivity, external services, etc.)
        return Ok(new { Status = "Ready", Timestamp = DateTime.UtcNow });
    }

    [HttpGet("live")]
    public IActionResult Live()
    {
        // Add liveness checks here (application responsiveness, memory usage, etc.)
        return Ok(new { Status = "Live", Timestamp = DateTime.UtcNow });
    }
}
'@ "Health check endpoints for container monitoring"

        # Create sample API controller
        Create-FileInteractive "ContainerAppsDemo.API/Controllers/ProductsController.cs" @'
using Microsoft.AspNetCore.Mvc;

namespace ContainerAppsDemo.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ILogger<ProductsController> _logger;
    private static readonly List<Product> Products = new()
    {
        new Product { Id = 1, Name = "Laptop", Price = 999.99m },
        new Product { Id = 2, Name = "Mouse", Price = 29.99m },
        new Product { Id = 3, Name = "Keyboard", Price = 79.99m }
    };

    public ProductsController(ILogger<ProductsController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public ActionResult<IEnumerable<Product>> Get()
    {
        _logger.LogInformation("Getting all products");
        return Ok(Products);
    }

    [HttpGet("{id}")]
    public ActionResult<Product> Get(int id)
    {
        _logger.LogInformation("Getting product with ID: {ProductId}", id);
        var product = Products.FirstOrDefault(p => p.Id == id);

        if (product == null)
        {
            return NotFound();
        }

        return Ok(product);
    }

    [HttpPost]
    public ActionResult<Product> Post([FromBody] Product product)
    {
        _logger.LogInformation("Creating new product: {ProductName}", product.Name);
        product.Id = Products.Max(p => p.Id) + 1;
        Products.Add(product);

        return CreatedAtAction(nameof(Get), new { id = product.Id }, product);
    }
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
}
'@ "Sample Products API controller for testing"

        # Create Docker Compose for local development
        Create-FileInteractive "docker-compose.yml" @'
version: '3.8'

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: containerappsdemo-api
    ports:
      - "8080:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: containerappsdemo-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      api:
        condition: service_healthy
    restart: unless-stopped

volumes:
  app_data:
'@ "Docker Compose configuration for local development and testing"

        # Create Nginx configuration
        Create-FileInteractive "nginx.conf" @'
events {
    worker_connections 1024;
}

http {
    upstream api {
        server api:8080;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            proxy_pass http://api/health;
            access_log off;
        }
    }
}
'@ "Nginx reverse proxy configuration"

        # Create .dockerignore
        Create-FileInteractive ".dockerignore" @'
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/azds.yaml
**/bin
**/charts
**/docker-compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
LICENSE
README.md
'@ "Docker ignore file to exclude unnecessary files from build context"

        # Create container security scanning script
        Create-FileInteractive "scan-security.ps1" @'
#!/usr/bin/env pwsh

# Container Security Scanning Script
Write-Host "🔒 Running container security scans..." -ForegroundColor Cyan

# Build the image
Write-Host "Building container image..." -ForegroundColor Yellow
docker build -t containerappsdemo:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build container image"
    exit 1
}

# Run Trivy security scan (if available)
Write-Host "Checking for Trivy scanner..." -ForegroundColor Yellow
if (Get-Command trivy -ErrorAction SilentlyContinue) {
    Write-Host "Running Trivy vulnerability scan..." -ForegroundColor Green
    trivy image --severity HIGH,CRITICAL containerappsdemo:latest
} else {
    Write-Warning "Trivy not found. Install with: brew install trivy (macOS) or apt-get install trivy (Ubuntu)"
}

# Run Docker Scout scan (if available)
Write-Host "Checking for Docker Scout..." -ForegroundColor Yellow
if (Get-Command docker-scout -ErrorAction SilentlyContinue) {
    Write-Host "Running Docker Scout scan..." -ForegroundColor Green
    docker scout cves containerappsdemo:latest
} else {
    Write-Warning "Docker Scout not found. Enable with: docker scout --help"
}

# Basic image analysis
Write-Host "Container image analysis:" -ForegroundColor Green
docker images containerappsdemo:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

Write-Host "✅ Security scan completed!" -ForegroundColor Green
'@ "Container security scanning script with Trivy and Docker Scout"
    }

    "exercise02" {
        # Exercise 2: Azure Deployment

        Explain-Concept "Azure Container Apps" @"
Azure Container Apps is a fully managed serverless container platform:
• Automatic scaling based on HTTP traffic, events, or CPU/memory usage
• Built-in load balancing and traffic splitting for blue-green deployments
• Integrated with Azure Container Registry for secure image storage
• Support for microservices patterns with service discovery
• Pay-per-use pricing model with scale-to-zero capabilities
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 2 requires Exercise 1 to be completed first!"
            Write-Info "Please run: .\launch-exercises.ps1 exercise01"
            exit 1
        }

        # Create Azure deployment script
        Create-FileInteractive "deploy-to-azure.ps1" @'
#!/usr/bin/env pwsh

# Azure Container Apps Deployment Script
param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-containerappsdemo",

    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory=$false)]
    [string]$ContainerAppName = "containerappsdemo",

    [Parameter(Mandatory=$false)]
    [string]$RegistryName = "acrcontainerappsdemo$(Get-Random -Minimum 1000 -Maximum 9999)"
)

Write-Host "🚀 Starting Azure Container Apps deployment..." -ForegroundColor Cyan
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

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Create Azure Container Registry
Write-Host "Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create --resource-group $ResourceGroupName --name $RegistryName --sku Basic --admin-enabled true

# Get ACR login server
$acrLoginServer = az acr show --name $RegistryName --query loginServer --output tsv
Write-Host "ACR Login Server: $acrLoginServer" -ForegroundColor Green

# Build and push image to ACR
Write-Host "Building and pushing container image..." -ForegroundColor Yellow
az acr build --registry $RegistryName --image containerappsdemo:latest .

# Create Container Apps environment
Write-Host "Creating Container Apps environment..." -ForegroundColor Yellow
$environmentName = "$ContainerAppName-env"
az containerapp env create --name $environmentName --resource-group $ResourceGroupName --location $Location

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
'@ "Complete Azure deployment script with Container Registry and Container Apps"
    }

    "exercise03" {
        # Exercise 3: CI/CD Pipeline

        Explain-Concept "GitHub Actions for Container Apps" @"
GitHub Actions provides automated CI/CD pipelines for containerized applications:
• Automated building and testing on code changes
• Secure deployment to Azure using service principals
• Multi-environment deployment strategies (dev, staging, production)
• Integration with Azure Container Registry for image management
• Automated rollback capabilities and deployment approvals
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03"
            exit 1
        }

        # Create GitHub Actions workflow
        Create-FileInteractive ".github/workflows/deploy.yml" @'
name: Build and Deploy to Azure Container Apps

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  AZURE_CONTAINER_REGISTRY: acrcontainerappsdemo
  CONTAINER_APP_NAME: containerappsdemo
  RESOURCE_GROUP: rg-containerappsdemo
  IMAGE_NAME: containerappsdemo

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 8.0.x

    - name: Restore dependencies
      run: dotnet restore ContainerAppsDemo.API/ContainerAppsDemo.API.csproj

    - name: Build
      run: dotnet build ContainerAppsDemo.API/ContainerAppsDemo.API.csproj --no-restore

    - name: Test
      run: dotnet test ContainerAppsDemo.API/ContainerAppsDemo.API.csproj --no-build --verbosity normal

  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
    - uses: actions/checkout@v4

    - name: Build Docker image
      run: docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: sarif
        output: trivy-results.sarif

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: trivy-results.sarif

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
    - uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push to ACR
      run: |
        az acr build --registry ${{ env.AZURE_CONTAINER_REGISTRY }} --image ${{ env.IMAGE_NAME }}:${{ github.sha }} .

    - name: Deploy to Container Apps (Staging)
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }}-staging \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.AZURE_CONTAINER_REGISTRY }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy-production:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
    - uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push to ACR
      run: |
        az acr build --registry ${{ env.AZURE_CONTAINER_REGISTRY }} --image ${{ env.IMAGE_NAME }}:${{ github.sha }} .
        az acr build --registry ${{ env.AZURE_CONTAINER_REGISTRY }} --image ${{ env.IMAGE_NAME }}:latest .

    - name: Deploy to Container Apps (Production)
      run: |
        az containerapp update \
          --name ${{ env.CONTAINER_APP_NAME }} \
          --resource-group ${{ env.RESOURCE_GROUP }} \
          --image ${{ env.AZURE_CONTAINER_REGISTRY }}.azurecr.io/${{ env.IMAGE_NAME }}:${{ github.sha }}
'@ "Complete CI/CD pipeline with multi-environment deployment and security scanning"
    }

    "exercise04" {
        # Exercise 4: Advanced Configuration

        Explain-Concept "Production-Ready Container Apps" @"
Production deployments require advanced configuration:
• Application Insights for telemetry and monitoring
• Custom domains with SSL certificates
• Advanced scaling policies and resource limits
• Service-to-service communication and networking
• Secrets management and configuration
"@

        if (-not $SkipProjectCreation) {
            Write-Error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
            Write-Info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
            exit 1
        }

        # Create Application Insights configuration
        Create-FileInteractive "ContainerAppsDemo.API/appsettings.json" @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    },
    "ApplicationInsights": {
      "LogLevel": {
        "Default": "Information"
      }
    }
  },
  "ApplicationInsights": {
    "ConnectionString": ""
  },
  "AllowedHosts": "*"
}
'@ "Application configuration with Application Insights integration"

        # Create advanced deployment script
        Create-FileInteractive "deploy-production.ps1" @'
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
'@ "Production deployment script with monitoring and custom domain setup"
    }
}

Write-Host ""
Write-Success "🎉 $ExerciseName template created successfully!"

Write-Host ""
Write-Success "🎉 $ExerciseName template created successfully!"
Write-Host ""
Write-Info "📋 Next steps based on exercise:"

switch ($ExerciseName) {
    "exercise01" {
        Write-Host "1. Build the container: docker build -t containerappsdemo ." -ForegroundColor Cyan
        Write-Host "2. Run locally: docker run -p 8080:8080 containerappsdemo" -ForegroundColor Cyan
        Write-Host "3. Test health check: curl http://localhost:8080/health" -ForegroundColor Cyan
        Write-Host "4. Use Docker Compose: docker-compose up" -ForegroundColor Cyan
    }
    "exercise02" {
        Write-Host "1. Login to Azure: az login" -ForegroundColor Cyan
        Write-Host "2. Run deployment: .\deploy-to-azure.ps1" -ForegroundColor Cyan
        Write-Host "3. Check deployment-info.txt for URLs and commands" -ForegroundColor Cyan
    }
    "exercise03" {
        Write-Host "1. Commit and push to GitHub repository" -ForegroundColor Cyan
        Write-Host "2. Set up Azure service principal for GitHub Actions" -ForegroundColor Cyan
        Write-Host "3. Configure repository secrets (AZURE_CREDENTIALS)" -ForegroundColor Cyan
        Write-Host "4. Monitor workflow runs in GitHub Actions" -ForegroundColor Cyan
    }
    "exercise04" {
        Write-Host "1. Deploy the enhanced application with monitoring" -ForegroundColor Cyan
        Write-Host "2. Configure Application Insights connection string" -ForegroundColor Cyan
        Write-Host "3. Set up custom domain and SSL certificate" -ForegroundColor Cyan
        Write-Host "4. Monitor application performance and health" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Info "📚 For detailed instructions, refer to the exercise guide files created."
Write-Info "🔗 Additional resources available in the Resources/ directory."

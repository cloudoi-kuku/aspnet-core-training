# E-Commerce Microservices Setup Script for Azure AKS (Module 13)
# This script sets up the complete development environment and builds Docker images

param(
    [switch]$SkipBuild,
    [switch]$SkipTest
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🚀 E-Commerce Microservices Platform Setup (Module 13)${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Check prerequisites
Write-Host "${Blue}🔍 Checking prerequisites...${Reset}"

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "${Green}✅ Docker: $dockerVersion${Reset}"
    
    docker info | Out-Null
    Write-Host "${Green}✅ Docker is running${Reset}"
}
catch {
    Write-Host "${Red}❌ Docker is not installed or not running. Please install and start Docker Desktop.${Reset}"
    exit 1
}

# Check .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Host "${Green}✅ .NET SDK: $dotnetVersion${Reset}"
}
catch {
    Write-Host "${Red}❌ .NET SDK is not installed. Please install .NET 8 SDK.${Reset}"
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "${Green}✅ Node.js: $nodeVersion${Reset}"
}
catch {
    Write-Host "${Red}❌ Node.js is not installed. Please install Node.js 18+.${Reset}"
    exit 1
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Host "${Green}✅ npm: $npmVersion${Reset}"
}
catch {
    Write-Host "${Red}❌ npm is not installed. Please install npm.${Reset}"
    exit 1
}

Write-Host "${Green}✅ All prerequisites are installed${Reset}"

# Validate port configurations
Write-Host ""
Write-Host "${Blue}🔍 Validating port configurations...${Reset}"
.\validate-ports.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Port validation failed. Please check the configuration.${Reset}"
    exit 1
}

# Setup backend
Write-Host ""
Write-Host "${Blue}🔧 Setting up .NET Backend...${Reset}"
Set-Location "src\backend\ECommerce.API"

# Restore NuGet packages
Write-Host "${Yellow}Restoring NuGet packages...${Reset}"
dotnet restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Failed to restore NuGet packages${Reset}"
    exit 1
}

# Build the project
Write-Host "${Yellow}Building .NET project...${Reset}"
dotnet build --configuration Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Failed to build .NET project${Reset}"
    exit 1
}

Write-Host "${Green}✅ Backend setup completed${Reset}"

# Setup frontend
Write-Host ""
Write-Host "${Blue}🔧 Setting up Next.js Frontend...${Reset}"
Set-Location "..\..\frontend"

# Install npm packages
Write-Host "${Yellow}Installing npm packages...${Reset}"
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Failed to install npm packages${Reset}"
    exit 1
}

if (-not $SkipBuild) {
    # Build the frontend
    Write-Host "${Yellow}Building Next.js project...${Reset}"
    npm run build

    if ($LASTEXITCODE -ne 0) {
        Write-Host "${Red}❌ Failed to build Next.js project${Reset}"
        exit 1
    }
}

Write-Host "${Green}✅ Frontend setup completed${Reset}"

# Return to root directory
Set-Location "..\..\"

# Create data directory
Write-Host ""
Write-Host "${Blue}📁 Creating data directories...${Reset}"
if (-not (Test-Path "data")) {
    New-Item -ItemType Directory -Path "data" | Out-Null
}
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

# Build Docker images
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "${Blue}🐳 Building Docker images...${Reset}"
    .\build-images.ps1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "${Red}❌ Failed to build Docker images${Reset}"
        exit 1
    }
}

# Test local setup
if (-not $SkipTest) {
    Write-Host ""
    Write-Host "${Blue}🧪 Testing local setup...${Reset}"

    # Start services with docker-compose
    Write-Host "${Yellow}Starting services with Docker Compose...${Reset}"
    docker-compose up -d

    if ($LASTEXITCODE -ne 0) {
        Write-Host "${Red}❌ Failed to start services with Docker Compose${Reset}"
        exit 1
    }

    # Wait for services to start
    Write-Host "${Yellow}Waiting for services to start...${Reset}"
    Start-Sleep -Seconds 10

    # Check if services are running
    $runningServices = docker-compose ps --services --filter "status=running"
    if ($runningServices) {
        Write-Host "${Green}✅ Services are running successfully${Reset}"
        
        Write-Host ""
        Write-Host "${Cyan}🌐 Application URLs:${Reset}"
        Write-Host "  Frontend: ${Green}http://localhost:3000${Reset}"
        Write-Host "  Backend API: ${Green}http://localhost:7000${Reset}"
        Write-Host "  Swagger UI: ${Green}http://localhost:7000/swagger${Reset}"
        Write-Host "  Redis: ${Green}localhost:6379${Reset}"
        
        Write-Host ""
        Write-Host "${Yellow}🔧 Useful Commands:${Reset}"
        Write-Host "  View logs: ${Cyan}docker-compose logs -f${Reset}"
        Write-Host "  Stop services: ${Cyan}docker-compose down${Reset}"
        Write-Host "  Restart services: ${Cyan}docker-compose restart${Reset}"
        Write-Host "  View running containers: ${Cyan}docker-compose ps${Reset}"
    } else {
        Write-Host "${Red}❌ Some services failed to start. Check logs with: docker-compose logs${Reset}"
    }
}

Write-Host ""
Write-Host "${Cyan}📋 Next Steps:${Reset}"
Write-Host "  1. Test the application locally: ${Green}http://localhost:3000${Reset}"
Write-Host "  2. Deploy to Azure AKS: ${Cyan}.\deploy-with-helm.ps1${Reset}"
Write-Host "  3. View application logs: ${Cyan}docker-compose logs -f${Reset}"
Write-Host "  4. Stop local services: ${Cyan}docker-compose down${Reset}"

Write-Host ""
Write-Host "${Yellow}💡 Development Tips:${Reset}"
Write-Host "  • Frontend source: ${Cyan}src\frontend\${Reset}"
Write-Host "  • Backend source: ${Cyan}src\backend\ECommerce.API\${Reset}"
Write-Host "  • Helm charts: ${Cyan}helm-charts\ecommerce-app\${Reset}"
Write-Host "  • Azure deployment: ${Cyan}.\deploy-with-helm.ps1${Reset}"

Write-Host ""
Write-Host "${Yellow}📚 Available Scripts (run from terraform directory):${Reset}"
Write-Host "  • Build images: ${Cyan}.\build-images.ps1${Reset}"
Write-Host "  • Deploy to AKS: ${Cyan}.\deploy-with-helm.ps1${Reset}"
Write-Host "  • Setup monitoring: ${Cyan}.\setup-monitoring.ps1${Reset}"
Write-Host "  • Cleanup: ${Cyan}.\cleanup.ps1${Reset}"

Write-Host ""
Write-Host "${Green}🎉 Setup completed successfully!${Reset}"
Write-Host "${Green}Your e-commerce platform is ready for development and deployment.${Reset}"

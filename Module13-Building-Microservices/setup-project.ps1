#!/usr/bin/env pwsh

# E-Commerce Full Stack Project Setup Script
# This script sets up the development environment for the e-commerce application

param(
    [switch]$SkipDependencyCheck,
    [switch]$SkipBuild,
    [switch]$Production
)

Write-Host "🚀 E-Commerce Full Stack Project Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (-not $SkipDependencyCheck) {
    Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow
    
    # Check Docker
    try {
        $dockerVersion = docker --version
        Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
        Write-Host "   Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        exit 1
    }
    
    # Check .NET SDK
    try {
        $dotnetVersion = dotnet --version
        Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ .NET SDK is not installed" -ForegroundColor Red
        Write-Host "   Please install .NET 8.0 SDK from https://dotnet.microsoft.com/download" -ForegroundColor Yellow
        exit 1
    }
    
    # Check Node.js
    try {
        $nodeVersion = node --version
        Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Node.js is not installed" -ForegroundColor Red
        Write-Host "   Please install Node.js 18+ from https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
    
    # Check kubectl
    try {
        $kubectlVersion = kubectl version --client --short 2>$null
        Write-Host "✅ kubectl: $kubectlVersion" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  kubectl is not installed (optional for local development)" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Set up environment variables
Write-Host "🔧 Setting up environment variables..." -ForegroundColor Yellow
$env:ASPNETCORE_ENVIRONMENT = if ($Production) { "Production" } else { "Development" }
$env:NODE_ENV = if ($Production) { "production" } else { "development" }

# Backend setup
Write-Host ""
Write-Host "📦 Setting up Backend..." -ForegroundColor Yellow
Set-Location "src/backend/ECommerce.API"

# Restore NuGet packages
Write-Host "  📥 Restoring NuGet packages..." -ForegroundColor Gray
dotnet restore

if (-not $SkipBuild) {
    # Build backend
    Write-Host "  🔨 Building backend..." -ForegroundColor Gray
    dotnet build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Backend build failed!" -ForegroundColor Red
        exit 1
    }
}

# Create data directory for SQLite
if (-not (Test-Path "data")) {
    New-Item -ItemType Directory -Path "data" | Out-Null
    Write-Host "  📁 Created data directory for SQLite" -ForegroundColor Gray
}

Set-Location "../../.."

# Frontend setup
Write-Host ""
Write-Host "📦 Setting up Frontend..." -ForegroundColor Yellow
Set-Location "src/frontend"

# Install npm packages
Write-Host "  📥 Installing npm packages..." -ForegroundColor Gray
npm install

if (-not $SkipBuild) {
    # Build frontend
    Write-Host "  🔨 Building frontend..." -ForegroundColor Gray
    npm run build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Frontend build failed!" -ForegroundColor Red
        exit 1
    }
}

Set-Location "../.."

# Docker setup
Write-Host ""
Write-Host "🐳 Building Docker images..." -ForegroundColor Yellow

# Build backend image
Write-Host "  🔨 Building backend Docker image..." -ForegroundColor Gray
docker build -t ecommerce-backend:latest -f src/backend/ECommerce.API/Dockerfile src/backend/ECommerce.API

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend Docker build failed!" -ForegroundColor Red
    exit 1
}

# Build frontend image
Write-Host "  🔨 Building frontend Docker image..." -ForegroundColor Gray
docker build -t ecommerce-frontend:latest -f src/frontend/Dockerfile src/frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend Docker build failed!" -ForegroundColor Red
    exit 1
}

# Create docker-compose for local development
Write-Host ""
Write-Host "📝 Creating docker-compose.yml for local development..." -ForegroundColor Yellow
$dockerComposeContent = @'
version: '3.8'

services:
  backend:
    image: ecommerce-backend:latest
    container_name: ecommerce-backend
    ports:
      - "7000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Data Source=/app/data/ecommerce.db
      - ConnectionStrings__Redis=redis:6379
      - JwtSettings__SecretKey=your-super-secret-jwt-key-change-this-in-production
      - JwtSettings__Issuer=ecommerce-api
      - JwtSettings__Audience=ecommerce-app
    volumes:
      - ./data:/app/data
    depends_on:
      - redis
    networks:
      - ecommerce-network

  frontend:
    image: ecommerce-frontend:latest
    container_name: ecommerce-frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:7000
    depends_on:
      - backend
    networks:
      - ecommerce-network

  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis
    ports:
      - "6379:6379"
    networks:
      - ecommerce-network

networks:
  ecommerce-network:
    driver: bridge
'@

Set-Content -Path "docker-compose.yml" -Value $dockerComposeContent

Write-Host ""
Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start the application with Docker Compose:" -ForegroundColor White
Write-Host "     docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Access the application:" -ForegroundColor White
Write-Host "     - Frontend: http://localhost:3000" -ForegroundColor Gray
Write-Host "     - Backend API: http://localhost:7000" -ForegroundColor Gray
Write-Host "     - API Docs: http://localhost:7000/swagger" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. For Kubernetes deployment:" -ForegroundColor White
Write-Host "     - Create a local cluster: kind create cluster --config kind-cluster-config.yaml" -ForegroundColor Gray
Write-Host "     - Deploy with Helm: helm install ecommerce ./helm-charts/ecommerce-app" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. For monitoring setup:" -ForegroundColor White
Write-Host "     - Run: ./setup-monitoring.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tip: Check DEPLOYMENT-GUIDE.md for detailed deployment instructions" -ForegroundColor Yellow
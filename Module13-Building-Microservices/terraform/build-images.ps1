# E-Commerce Platform Docker Image Build Script for Azure AKS
# This script builds the frontend and backend Docker images for deployment

param(
    [string]$Registry = "",
    [string]$Tag = "latest"
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🐳 Building E-Commerce Platform Docker Images${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Configuration
$FrontendImage = "ecommerce-frontend"
$BackendImage = "ecommerce-backend"

if ($Registry) {
    $FrontendImage = "$Registry/$FrontendImage"
    $BackendImage = "$Registry/$BackendImage"
}

Write-Host "${Blue}📋 Build Configuration:${Reset}"
Write-Host "  Registry: $(if ($Registry) { $Registry } else { 'local' })"
Write-Host "  Tag: $Tag"
Write-Host "  Frontend Image: ${FrontendImage}:${Tag}"
Write-Host "  Backend Image: ${BackendImage}:${Tag}"
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "${Green}✅ Docker is running${Reset}"
}
catch {
    Write-Host "${Red}❌ Docker is not running. Please start Docker first.${Reset}"
    exit 1
}

# Check if source directories exist
if (-not (Test-Path "src\frontend")) {
    Write-Host "${Red}❌ Frontend source directory not found: src\frontend${Reset}"
    Write-Host "${Yellow}Make sure you're running this script from the terraform directory${Reset}"
    exit 1
}

if (-not (Test-Path "src\backend")) {
    Write-Host "${Red}❌ Backend source directory not found: src\backend${Reset}"
    Write-Host "${Yellow}Make sure you're running this script from the terraform directory${Reset}"
    exit 1
}

# Build Frontend Image
Write-Host "${Blue}🔨 Building Frontend Docker Image...${Reset}"
Write-Host "${Yellow}Building Next.js SSR application...${Reset}"

Set-Location "src\frontend"

# Check if package.json exists
if (-not (Test-Path "package.json")) {
    Write-Host "${Red}❌ package.json not found in src\frontend${Reset}"
    exit 1
}

# Build the frontend image
$frontendBuildArgs = @(
    "build",
    "--tag", "${FrontendImage}:${Tag}",
    "--file", "Dockerfile",
    "--build-arg", "NODE_ENV=production",
    "--build-arg", "NEXT_PUBLIC_API_URL=http://ecommerce-app-backend:7000",
    "."
)

Write-Host "${Yellow}Running: docker $($frontendBuildArgs -join ' ')${Reset}"
& docker @frontendBuildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Frontend Docker build failed!${Reset}"
    exit 1
}

Write-Host "${Green}✅ Frontend image built successfully: ${FrontendImage}:${Tag}${Reset}"

Set-Location "..\..\"

# Build Backend Image
Write-Host "${Blue}🔨 Building Backend Docker Image...${Reset}"
Write-Host "${Yellow}Building .NET 8 API application...${Reset}"

Set-Location "src\backend\ECommerce.API"

# Check if project file exists
if (-not (Test-Path "ECommerce.API.csproj")) {
    Write-Host "${Red}❌ ECommerce.API.csproj not found in src\backend\ECommerce.API${Reset}"
    exit 1
}

# Build the backend image
$backendBuildArgs = @(
    "build",
    "--tag", "${BackendImage}:${Tag}",
    "--file", "Dockerfile",
    "--build-arg", "ASPNETCORE_ENVIRONMENT=Production",
    "."
)

Write-Host "${Yellow}Running: docker $($backendBuildArgs -join ' ')${Reset}"
& docker @backendBuildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Backend Docker build failed!${Reset}"
    exit 1
}

Write-Host "${Green}✅ Backend image built successfully: ${BackendImage}:${Tag}${Reset}"

Set-Location "..\..\..\"

# List built images
Write-Host ""
Write-Host "${Cyan}📦 Built Images:${Reset}"
docker images | Select-String -Pattern "(ecommerce-frontend|ecommerce-backend)" | Select-Object -First 10

# Test images (basic smoke test)
Write-Host ""
Write-Host "${Blue}🧪 Testing Images...${Reset}"

# Test frontend image
Write-Host "${Yellow}Testing frontend image...${Reset}"
$frontendTest = docker run --rm -d -p 3001:3000 "${FrontendImage}:${Tag}"
Start-Sleep -Seconds 5

$frontendRunning = docker ps | Select-String $frontendTest
if ($frontendRunning) {
    Write-Host "${Green}✅ Frontend image starts successfully${Reset}"
    docker stop $frontendTest | Out-Null
} else {
    Write-Host "${Red}❌ Frontend image failed to start${Reset}"
}

# Test backend image
Write-Host "${Yellow}Testing backend image...${Reset}"
$backendTest = docker run --rm -d -p 7001:7000 -p 7002:7001 "${BackendImage}:${Tag}"
Start-Sleep -Seconds 5

$backendRunning = docker ps | Select-String $backendTest
if ($backendRunning) {
    Write-Host "${Green}✅ Backend image starts successfully${Reset}"
    docker stop $backendTest | Out-Null
} else {
    Write-Host "${Red}❌ Backend image failed to start${Reset}"
}

Write-Host ""
Write-Host "${Green}🎉 All images built successfully!${Reset}"

# Push to registry if specified
if ($Registry) {
    Write-Host ""
    Write-Host "${Blue}📤 Pushing images to registry...${Reset}"
    
    Write-Host "${Yellow}Pushing frontend image...${Reset}"
    docker push "${FrontendImage}:${Tag}"
    
    Write-Host "${Yellow}Pushing backend image...${Reset}"
    docker push "${BackendImage}:${Tag}"
    
    Write-Host "${Green}✅ Images pushed to registry successfully!${Reset}"
}

Write-Host ""
Write-Host "${Cyan}📋 Next Steps:${Reset}"
Write-Host "  1. Deploy to Azure AKS: ${Cyan}.\terraform\deploy-with-helm.ps1${Reset}"
Write-Host "  2. Test locally: ${Cyan}docker-compose up${Reset}"
Write-Host "  3. View images: ${Cyan}docker images | Select-String ecommerce${Reset}"

if ($Registry) {
    Write-Host "  4. Update Helm values with registry: ${Cyan}$Registry${Reset}"
}

Write-Host ""
Write-Host "${Yellow}💡 Tips:${Reset}"
Write-Host "  • Use -Registry parameter to push to a registry"
Write-Host "  • Use -Tag parameter to use a specific tag"
Write-Host "  • Example: .\build-images.ps1 -Registry myregistry.azurecr.io -Tag v1.0.0"

Write-Host ""
Write-Host "${Green}✅ Build process completed successfully!${Reset}"

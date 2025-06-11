# Fix Port 5050 Configuration and Connection Issues
# This script rebuilds images and fixes the IPv6/IPv4 connection issue

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🔧 Fixing Port 5050 Configuration${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

# Stop any running containers
Write-Host "${Blue}🛑 Stopping existing containers...${Reset}"
docker-compose down

# Remove old images to force rebuild
Write-Host "${Blue}🗑️  Removing old images...${Reset}"
docker rmi ecommerce-frontend:latest -f 2>$null
docker rmi ecommerce-backend:latest -f 2>$null

# Rebuild images with new port configuration
Write-Host "${Blue}🔨 Rebuilding images with port 5050...${Reset}"

# Build backend
Write-Host "${Yellow}Building backend image...${Reset}"
Set-Location "src\backend\ECommerce.API"
docker build -t ecommerce-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Backend build failed!${Reset}"
    exit 1
}
Set-Location "..\..\..\"

# Build frontend
Write-Host "${Yellow}Building frontend image...${Reset}"
Set-Location "src\frontend"
docker build -t ecommerce-frontend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}❌ Frontend build failed!${Reset}"
    exit 1
}
Set-Location "..\..\"

# Start services
Write-Host "${Blue}🚀 Starting services with new configuration...${Reset}"
docker-compose up -d

# Wait for services to start
Write-Host "${Yellow}⏳ Waiting for services to start...${Reset}"
Start-Sleep -Seconds 10

# Check if services are running
Write-Host "${Blue}🔍 Checking service status...${Reset}"
$backendRunning = docker ps --filter "name=ecommerce-backend" --filter "status=running" -q
$frontendRunning = docker ps --filter "name=ecommerce-frontend" --filter "status=running" -q

if ($backendRunning) {
    Write-Host "${Green}✅ Backend is running on port 5050${Reset}"
} else {
    Write-Host "${Red}❌ Backend failed to start${Reset}"
    Write-Host "${Yellow}Backend logs:${Reset}"
    docker logs ecommerce-backend --tail 20
}

if ($frontendRunning) {
    Write-Host "${Green}✅ Frontend is running on port 5050${Reset}"
} else {
    Write-Host "${Red}❌ Frontend failed to start${Reset}"
    Write-Host "${Yellow}Frontend logs:${Reset}"
    docker logs ecommerce-frontend --tail 20
}

# Test backend API
Write-Host "${Blue}🧪 Testing backend API...${Reset}"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5050/api/health" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "${Green}✅ Backend API is responding${Reset}"
    } else {
        Write-Host "${Yellow}⚠️  Backend API returned status: $($response.StatusCode)${Reset}"
    }
} catch {
    Write-Host "${Red}❌ Backend API test failed: $($_.Exception.Message)${Reset}"
}

# Test frontend
Write-Host "${Blue}🧪 Testing frontend...${Reset}"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5050" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "${Green}✅ Frontend is responding${Reset}"
    } else {
        Write-Host "${Yellow}⚠️  Frontend returned status: $($response.StatusCode)${Reset}"
    }
} catch {
    Write-Host "${Red}❌ Frontend test failed: $($_.Exception.Message)${Reset}"
}

Write-Host ""
Write-Host "${Cyan}📋 Service Information:${Reset}"
Write-Host "  Frontend: ${Green}http://localhost:5050${Reset}"
Write-Host "  Backend API: ${Green}http://localhost:5050/api${Reset}"
Write-Host "  Backend Health: ${Green}http://localhost:5050/api/health${Reset}"
Write-Host "  Redis: ${Green}localhost:6379${Reset}"

Write-Host ""
Write-Host "${Yellow}🔧 Troubleshooting Commands:${Reset}"
Write-Host "  View all logs: ${Cyan}docker-compose logs -f${Reset}"
Write-Host "  View backend logs: ${Cyan}docker logs ecommerce-backend -f${Reset}"
Write-Host "  View frontend logs: ${Cyan}docker logs ecommerce-frontend -f${Reset}"
Write-Host "  Check running containers: ${Cyan}docker ps${Reset}"
Write-Host "  Restart services: ${Cyan}docker-compose restart${Reset}"

Write-Host ""
Write-Host "${Blue}💡 Key Changes Made:${Reset}"
Write-Host "  • Both frontend and backend now use port 5050"
Write-Host "  • Backend metrics on port 5051"
Write-Host "  • Frontend connects to backend via Docker network (not localhost)"
Write-Host "  • Backend binds to 0.0.0.0 to accept connections from containers"

if ($backendRunning -and $frontendRunning) {
    Write-Host ""
    Write-Host "${Green}🎉 All services are running! Try accessing http://localhost:5050${Reset}"
} else {
    Write-Host ""
    Write-Host "${Red}❌ Some services failed to start. Check the logs above for details.${Reset}"
}

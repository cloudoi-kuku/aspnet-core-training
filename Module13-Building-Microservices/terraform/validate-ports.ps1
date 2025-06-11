# Port Validation Script for E-Commerce Platform
# This script validates that all port configurations are consistent across all deployment files

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🔍 Validating Port Configurations${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

$errors = @()
$warnings = @()

# Expected port configuration
$expectedPorts = @{
    "frontend.service.port" = 3000
    "frontend.service.targetPort" = 3000
    "backend.service.port" = 7000
    "backend.service.targetPort" = 7000
    "backend.service.metricsPort" = 7001
}

Write-Host "${Blue}📋 Expected Port Configuration:${Reset}"
Write-Host "  Frontend Service: 3000 → 3000"
Write-Host "  Backend Service: 7000 → 7000"
Write-Host "  Backend Metrics: 7001"
Write-Host "  Redis: 6379"
Write-Host "  RabbitMQ: 5672"
Write-Host ""

# Function to check YAML values
function Test-YamlValue {
    param($file, $path, $expectedValue, $description)
    
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        # Simple YAML parsing for port values
        $pattern = "$path\s*:\s*(\d+)"
        if ($content -match $pattern) {
            $actualValue = [int]$matches[1]
            if ($actualValue -eq $expectedValue) {
                Write-Host "${Green}✅ $description`: $actualValue${Reset}"
                return $true
            } else {
                Write-Host "${Red}❌ $description`: Expected $expectedValue, found $actualValue${Reset}"
                $script:errors += "$file - $description port mismatch"
                return $false
            }
        } else {
            Write-Host "${Yellow}⚠️  $description`: Not found in $file${Reset}"
            $script:warnings += "$file - $description not found"
            return $false
        }
    } else {
        Write-Host "${Red}❌ File not found: $file${Reset}"
        $script:errors += "Missing file: $file"
        return $false
    }
}

# Function to check Dockerfile EXPOSE statements
function Test-DockerfileExpose {
    param($file, $expectedPorts, $description)
    
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $exposePattern = "EXPOSE\s+([\d\s]+)"
        if ($content -match $exposePattern) {
            $exposedPorts = $matches[1] -split '\s+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
            $allPortsFound = $true
            foreach ($port in $expectedPorts) {
                if ($exposedPorts -contains $port) {
                    Write-Host "${Green}✅ $description EXPOSE $port${Reset}"
                } else {
                    Write-Host "${Red}❌ $description missing EXPOSE $port${Reset}"
                    $script:errors += "$file - Missing EXPOSE $port"
                    $allPortsFound = $false
                }
            }
            return $allPortsFound
        } else {
            Write-Host "${Red}❌ $description`: No EXPOSE statement found${Reset}"
            $script:errors += "$file - No EXPOSE statement"
            return $false
        }
    } else {
        Write-Host "${Red}❌ File not found: $file${Reset}"
        $script:errors += "Missing file: $file"
        return $false
    }
}

# Check Helm values.yaml
Write-Host "${Blue}🔧 Checking Helm values.yaml...${Reset}"
Test-YamlValue "helm-charts\ecommerce-app\values.yaml" "frontend:\s+service:\s+port" 3000 "Frontend service port"
Test-YamlValue "helm-charts\ecommerce-app\values.yaml" "frontend:\s+service:\s+targetPort" 3000 "Frontend target port"
Test-YamlValue "helm-charts\ecommerce-app\values.yaml" "backend:\s+service:\s+port" 7000 "Backend service port"
Test-YamlValue "helm-charts\ecommerce-app\values.yaml" "backend:\s+service:\s+targetPort" 7000 "Backend target port"
Test-YamlValue "helm-charts\ecommerce-app\values.yaml" "backend:\s+service:\s+metricsPort" 7001 "Backend metrics port"

Write-Host ""

# Check Azure values.yaml
Write-Host "${Blue}🔧 Checking Azure values.yaml...${Reset}"
Test-YamlValue "helm-charts\azure-values.yaml" "service:\s+port" 3000 "Azure Frontend service port"
Test-YamlValue "helm-charts\azure-values.yaml" "service:\s+targetPort" 3000 "Azure Frontend target port"

Write-Host ""

# Check Dockerfiles
Write-Host "${Blue}🐳 Checking Dockerfiles...${Reset}"
Test-DockerfileExpose "src\frontend\Dockerfile" @(3000) "Frontend Dockerfile"
Test-DockerfileExpose "src\backend\ECommerce.API\Dockerfile" @(7000, 7001) "Backend Dockerfile"

Write-Host ""

# Check docker-compose.yml
Write-Host "${Blue}🐳 Checking docker-compose.yml...${Reset}"
if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    
    # Check frontend ports
    if ($composeContent -match '"3000:3000"') {
        Write-Host "${Green}✅ Docker Compose frontend ports: 3000:3000${Reset}"
    } else {
        Write-Host "${Red}❌ Docker Compose frontend ports incorrect${Reset}"
        $errors += "docker-compose.yml - Frontend port mapping incorrect"
    }
    
    # Check backend ports
    if ($composeContent -match '"7000:7000"' -and $composeContent -match '"7001:7001"') {
        Write-Host "${Green}✅ Docker Compose backend ports: 7000:7000, 7001:7001${Reset}"
    } else {
        Write-Host "${Red}❌ Docker Compose backend ports incorrect${Reset}"
        $errors += "docker-compose.yml - Backend port mapping incorrect"
    }
} else {
    Write-Host "${Red}❌ docker-compose.yml not found${Reset}"
    $errors += "Missing docker-compose.yml"
}

Write-Host ""

# Check Prometheus scrape configs
Write-Host "${Blue}📊 Checking Prometheus scrape configurations...${Reset}"
$valuesFiles = @("helm-charts\ecommerce-app\values.yaml", "helm-charts\azure-values.yaml")
foreach ($file in $valuesFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match "ecommerce-app-frontend:3000") {
            Write-Host "${Green}✅ $file - Frontend scrape target: 3000${Reset}"
        } else {
            Write-Host "${Yellow}⚠️  $file - Frontend scrape target not found or incorrect${Reset}"
            $warnings += "$file - Frontend scrape target"
        }
        
        if ($content -match "ecommerce-app-backend:7001") {
            Write-Host "${Green}✅ $file - Backend scrape target: 7001${Reset}"
        } else {
            Write-Host "${Yellow}⚠️  $file - Backend scrape target not found or incorrect${Reset}"
            $warnings += "$file - Backend scrape target"
        }
    }
}

Write-Host ""

# Summary
Write-Host "${Cyan}📋 Validation Summary:${Reset}"
Write-Host "${Cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "${Green}🎉 All port configurations are correct!${Reset}"
    Write-Host "${Green}✅ No errors or warnings found${Reset}"
} else {
    if ($errors.Count -gt 0) {
        Write-Host "${Red}❌ Found $($errors.Count) error(s):${Reset}"
        foreach ($error in $errors) {
            Write-Host "  ${Red}• $error${Reset}"
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "${Yellow}⚠️  Found $($warnings.Count) warning(s):${Reset}"
        foreach ($warning in $warnings) {
            Write-Host "  ${Yellow}• $warning${Reset}"
        }
    }
}

Write-Host ""
Write-Host "${Blue}💡 Port Configuration Reference:${Reset}"
Write-Host "  Frontend: 3000 (HTTP + Metrics)"
Write-Host "  Backend: 7000 (HTTP), 7001 (Metrics)"
Write-Host "  Redis: 6379"
Write-Host "  RabbitMQ: 5672"
Write-Host "  Prometheus: 9090"
Write-Host "  Grafana: 80 (service), 3000 (container)"

if ($errors.Count -gt 0) {
    exit 1
} else {
    exit 0
}

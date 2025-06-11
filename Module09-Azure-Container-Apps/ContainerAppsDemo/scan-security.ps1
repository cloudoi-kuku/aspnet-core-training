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

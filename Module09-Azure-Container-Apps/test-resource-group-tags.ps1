#!/usr/bin/env pwsh

# Test script to verify resource group tags

Write-Host "Testing resource group creation with tags..." -ForegroundColor Cyan

# Test variables
$TestStudentId = "test123"
$TestResourceGroup = "rg-test-tags-$(Get-Random -Minimum 1000 -Maximum 9999)"
$TestLocation = "eastus"

# Create resource group with tags
Write-Host "Creating test resource group: $TestResourceGroup" -ForegroundColor Yellow
az group create `
    --name $TestResourceGroup `
    --location $TestLocation `
    --tags "enablon:contact=$TestStudentId@example.com" "enablon:owner=Environmental" "enablon:client=Enablon Internal" "enablon:cost_center=Environmental"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource group created successfully!" -ForegroundColor Green
    
    # Verify tags
    Write-Host "`nVerifying tags..." -ForegroundColor Yellow
    $tags = az group show --name $TestResourceGroup --query tags --output json | ConvertFrom-Json
    
    Write-Host "`nTags found:" -ForegroundColor Cyan
    $tags | Format-Table -AutoSize
    
    # Cleanup
    Write-Host "`nCleaning up test resource group..." -ForegroundColor Yellow
    az group delete --name $TestResourceGroup --yes --no-wait
    
    Write-Host "✅ Test completed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
}
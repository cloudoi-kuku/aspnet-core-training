# Test Deployment Script
# This script validates the Terraform configuration

Write-Host "🧪 Testing Terraform Configuration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if terraform is initialized
if (-not (Test-Path ".terraform")) {
    Write-Host "⚠️  Terraform not initialized. Running terraform init..." -ForegroundColor Yellow
    terraform init
}

# Validate configuration
Write-Host "📋 Validating Terraform configuration..." -ForegroundColor Blue
$validateResult = terraform validate -json | ConvertFrom-Json

if ($validateResult.valid) {
    Write-Host "✅ Configuration is valid" -ForegroundColor Green
} else {
    Write-Host "❌ Configuration has errors:" -ForegroundColor Red
    foreach ($diag in $validateResult.diagnostics) {
        Write-Host "   - $($diag.summary)" -ForegroundColor Red
    }
    exit 1
}

# Format check
Write-Host ""
Write-Host "📋 Checking Terraform formatting..." -ForegroundColor Blue
$formatCheck = terraform fmt -check -recursive

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All files are properly formatted" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some files need formatting. Run: terraform fmt -recursive" -ForegroundColor Yellow
}

# Show what will be created
Write-Host ""
Write-Host "📋 Resources that will be created:" -ForegroundColor Blue
Write-Host ""

# Create a temporary plan
terraform plan -out=temp.plan > $null 2>&1
$planOutput = terraform show -json temp.plan | ConvertFrom-Json
Remove-Item temp.plan -Force

$resourceCount = @{}
foreach ($change in $planOutput.resource_changes) {
    if ($change.change.actions -contains "create") {
        $type = $change.type
        if ($resourceCount.ContainsKey($type)) {
            $resourceCount[$type]++
        } else {
            $resourceCount[$type] = 1
        }
    }
}

foreach ($type in $resourceCount.Keys | Sort-Object) {
    $friendlyName = switch ($type) {
        "azurerm_resource_group" { "Resource Group" }
        "azurerm_container_registry" { "Container Registry" }
        "azurerm_log_analytics_workspace" { "Log Analytics Workspace" }
        "azurerm_application_insights" { "Application Insights" }
        "azurerm_container_app_environment" { "Container Apps Environment" }
        "azurerm_mssql_server" { "SQL Server" }
        "azurerm_mssql_database" { "SQL Database" }
        "azurerm_mssql_firewall_rule" { "SQL Firewall Rule" }
        "azurerm_container_app" { "Container App" }
        "random_string" { "Random ID Generator" }
        "local_file" { "Configuration File" }
        "null_resource" { "Build Script" }
        default { $type }
    }
    Write-Host "  • $friendlyName`: $($resourceCount[$type])" -ForegroundColor White
}

Write-Host ""
Write-Host "💰 Estimated Cost: ~`$30/month (minimal usage)" -ForegroundColor Yellow
Write-Host ""

# Show example resource names
Write-Host "📝 Example Resource Names (with random suffix):" -ForegroundColor Blue
Write-Host "  • Resource Group: rg-microservices-abc12xyz" -ForegroundColor Gray
Write-Host "  • Container Registry: acrmicroservicesabc12xyz" -ForegroundColor Gray
Write-Host "  • SQL Server: sql-microservices-abc12xyz" -ForegroundColor Gray
Write-Host "  • Container Apps: ecommerce-backend, ecommerce-frontend" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Configuration test complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To deploy, run:" -ForegroundColor White
Write-Host "  terraform apply" -ForegroundColor Cyan
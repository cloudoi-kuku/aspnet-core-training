# Migration Script: From PowerShell to Terraform
# This script helps users transition from the PowerShell-based deployment to Terraform

param(
    [Parameter(Mandatory=$false)]
    [string]$ExistingConfigPath = "../../AzureECommerce/azure-config.ps1",
    
    [Parameter(Mandatory=$false)]
    [switch]$ImportExisting,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateTfvars
)

Write-Host "🚀 Module 13: PowerShell to Terraform Migration Helper" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Function to extract values from existing azure-config.ps1
function Get-ExistingConfig {
    param([string]$ConfigPath)
    
    if (Test-Path $ConfigPath) {
        Write-Host "✅ Found existing configuration at: $ConfigPath" -ForegroundColor Green
        
        # Source the configuration
        . $ConfigPath
        
        return @{
            ResourceGroup = $RESOURCE_GROUP
            CostCenter = $COST_CENTER
            Owner = $OWNER
            Contact = $CONTACT
        }
    }
    else {
        Write-Host "⚠️  No existing configuration found at: $ConfigPath" -ForegroundColor Yellow
        return $null
    }
}

# Function to generate terraform.tfvars from existing config
function New-TerraformVars {
    param($Config)
    
    if ($null -eq $Config) {
        Write-Host "❌ No configuration to convert" -ForegroundColor Red
        return
    }
    
    $tfvarsContent = @"
# Generated from existing PowerShell configuration
# Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# Resources will be created with a unique random identifier

# Azure Region
location = "westus"

# Common Tags (from existing config)
common_tags = {
  ManagedBy             = "Terraform"
  Environment           = "Training"
  Project              = "Microservices"
  Module               = "Module13"
  "enablon:client"      = "Enablon Internal"
  "enablon:cost_center" = "$($Config.CostCenter)"
  "enablon:owner"       = "$($Config.Owner)"
  "enablon:contact"     = "$($Config.Contact)"
}

# SQL Server Configuration
sql_admin_username = "sqladmin"
sql_admin_password = "P@ssw0rd$(Get-Random -Minimum 1000 -Maximum 9999)!"

# Container App Configuration
container_cpu    = 0.5
container_memory = "1.0Gi"

# Scaling Configuration
min_replicas = 1
max_replicas = 3

# Additional Tags
tags = {
  Purpose       = "Training"
  Course        = "ASP.NET Core Microservices"
  MigratedFrom  = "PowerShell"
  MigrationDate = "$(Get-Date -Format "yyyy-MM-dd")"
}

# Feature Flags
enable_monitoring        = true
enable_auto_scaling      = true
enable_service_discovery = true
"@

    $tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
    Write-Host "✅ Generated terraform.tfvars from existing configuration" -ForegroundColor Green
}

# Main migration process
Write-Host "📋 Checking for existing PowerShell-based deployment..." -ForegroundColor Blue

$existingConfig = Get-ExistingConfig -ConfigPath $ExistingConfigPath

if ($existingConfig) {
    Write-Host ""
    Write-Host "Found existing deployment: $($existingConfig.ResourceGroup)" -ForegroundColor Yellow
    Write-Host "Note: Terraform will create new resources with a unique ID" -ForegroundColor Yellow
    Write-Host ""
    
    if ($GenerateTfvars -or (Read-Host "Generate terraform.tfvars from existing config? (Y/n)") -ne 'n') {
        New-TerraformVars -Config $existingConfig
    }
}

Write-Host ""
Write-Host "📚 Migration Steps:" -ForegroundColor Blue
Write-Host ""
Write-Host "1. Review generated terraform.tfvars" -ForegroundColor White
Write-Host "2. Update the SQL password (auto-generated for security)" -ForegroundColor White
Write-Host "3. Run: terraform init" -ForegroundColor Cyan
Write-Host "4. Run: terraform plan" -ForegroundColor Cyan
Write-Host "5. Run: terraform apply" -ForegroundColor Cyan
Write-Host ""

if ($ImportExisting -and $existingConfig) {
    Write-Host "⚠️  Import Existing Resources:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If you want to import existing resources instead of creating new ones:" -ForegroundColor White
    Write-Host ""
    Write-Host "terraform import azurerm_resource_group.main /subscriptions/{subscription-id}/resourceGroups/$($existingConfig.ResourceGroup)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: You'll need to import each resource individually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 Comparison: PowerShell vs Terraform" -ForegroundColor Blue
Write-Host ""
Write-Host "PowerShell Approach:" -ForegroundColor Yellow
Write-Host "  ❌ Manual state tracking" -ForegroundColor Red
Write-Host "  ❌ No rollback capability" -ForegroundColor Red
Write-Host "  ❌ Imperative (how to do)" -ForegroundColor Red
Write-Host "  ✅ Simple for one-time setup" -ForegroundColor Green
Write-Host ""
Write-Host "Terraform Approach:" -ForegroundColor Yellow
Write-Host "  ✅ Automatic state management" -ForegroundColor Green
Write-Host "  ✅ Easy rollback and updates" -ForegroundColor Green
Write-Host "  ✅ Declarative (what to do)" -ForegroundColor Green
Write-Host "  ✅ Version control friendly" -ForegroundColor Green
Write-Host "  ✅ Reusable and modular" -ForegroundColor Green
Write-Host ""

Write-Host "💡 Tips:" -ForegroundColor Blue
Write-Host "  • Use 'terraform plan' to preview changes" -ForegroundColor White
Write-Host "  • Use 'terraform apply -auto-approve' to skip confirmation" -ForegroundColor White
Write-Host "  • Use 'terraform destroy' to clean up all resources" -ForegroundColor White
Write-Host "  • Check terraform.tfstate for resource details" -ForegroundColor White
Write-Host ""

Write-Host "✅ Ready to use Terraform for your microservices deployment!" -ForegroundColor Green